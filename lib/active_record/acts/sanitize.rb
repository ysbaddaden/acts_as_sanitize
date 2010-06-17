module ActiveRecord
  module Acts # :nodoc:
    module Sanitize # :nodoc:
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        # This +acts_as+ extension provides the capabilities of sanitizing
        # model attributes, in order to keep your database clean.
        # 
        # Example:
        # 
        #   class Post < ActiveRecord::Base
        #     acts_as_sanitize :title, :body, :on => :save
        #   end
        # 
        # The Post model will then sanitize the :title and :body columns on
        # :before_save.
        # 
        # Options:
        # 
        # - +:on+ - can be either +:validation+ (default), +:save+, +:create+ or +:update+.
        # 
        def acts_as_sanitize(*args)
          options = args.extract_options!
          
          before_handler = case options[:on]
          when :save
            'before_save'
          when :create
            'before_create'
          when :update
            'before_update'
          else
            'before_validation'
          end
          
          class_eval <<-EOV
            include ActiveRecord::Acts::Sanitize::InstanceMethods
            
            #{before_handler} :sanitize_attributes
            
            def columns_to_sanitize
              #{args.inspect}
            end
          EOV
        end
      end
      
      # Actual methods used within your model.
      module InstanceMethods
        protected
          def sanitize_attributes
            columns_to_sanitize.each do |column_name|
              sanitize_attribute(column_name) unless self[column_name].nil?
            end
          end

          def sanitize_attribute(column_name)
            self[column_name] = _sanitizer.sanitize(self[column_name].strip)
          end
        
        private
          def _sanitizer
            @_sanitizer ||= HTML::FullSanitizer.new
          end
      end
    end
  end
end

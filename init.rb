$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'active_record/acts/sanitize'
ActiveRecord::Base.class_eval { include ActiveRecord::Acts::Sanitize }

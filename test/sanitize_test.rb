require 'test/unit'
require 'rubygems'

gem 'actionpack', '>= 3.0.0.beta1'
require 'action_controller'

gem 'activerecord', '>= 3.0.0.beta1'
require 'active_record'

require "#{File.dirname(__FILE__)}/../init"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

class Post < ActiveRecord::Base
  acts_as_sanitize :title, :body
end

class Forum < ActiveRecord::Base
  acts_as_sanitize :title, :on => :save
end

class Story < ActiveRecord::Base
  acts_as_sanitize :title, :on => :create
end

class Page < ActiveRecord::Base
  acts_as_sanitize :title, :on => :update
end

class SanitizeTest < Test::Unit::TestCase
  def setup
    ActiveRecord::Schema.define(:version => 1) do
      create_table :posts do |t|
        t.string :title
        t.string :body
        t.string :more
      end
      create_table :forums do |t|
        t.string :title
      end
      create_table :stories do |t|
        t.string :title
      end
      create_table :pages do |t|
        t.string :title
      end
    end
  end

  def teardown
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end

  def test_sanitize
    post = Post.new(:title => 'a <title>title</title>',
      :body => 'a <body>body</body> with <hr/>',
      :more => '<span>test</span>')
    post.valid?
    assert_equal 'a title', post.title
    assert_equal 'a body with ', post.body
    assert_equal '<span>test</span>', post.more
  end

  def test_sanitize_on_save
    # create
    forum = Forum.new(:title => 'a <title>title</title>')
    forum.valid?
    assert_equal 'a <title>title</title>', forum.title
    forum.save!
    assert_equal 'a title', forum.title
    
    # update
    forum.title = 'an <strong>another</strong> title'
    forum.valid?
    assert_equal 'an <strong>another</strong> title', forum.title
    forum.save!
    assert_equal 'an another title', forum.title
  end

  def test_sanitize_on_create
    # create
    story = Story.new(:title => 'a <title>title</title>')
    story.valid?
    assert_equal 'a <title>title</title>', story.title
    story.save!
    assert_equal 'a title', story.title
    
    # update
    story.title = 'an <strong>another</strong> title'
    story.save!
    assert_equal 'an <strong>another</strong> title', story.title
  end

  def test_sanitize_on_update
    # create
    page = Page.new(:title => 'a <title>title</title>')
    page.valid?
    assert_equal 'a <title>title</title>', page.title
    page.save!
    assert_equal 'a <title>title</title>', page.title
    
    # update
    page.title = 'an <strong>another</strong> title'
    page.save!
    assert_equal 'an another title', page.title
  end
end

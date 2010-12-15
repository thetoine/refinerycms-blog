class Blog < ActiveRecord::Base
  
  has_many :blog_posts
  
end
class Blog < ActiveRecord::Base
  
  has_many :blog_posts
  
  has_friendly_id :title, :use_slug => true
  
end
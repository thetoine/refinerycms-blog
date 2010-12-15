class BlogPost < ActiveRecord::Base

  belongs_to :blog

  has_many :comments, :class_name => 'BlogComment'
  has_and_belongs_to_many :categories, :class_name => 'BlogCategory'

  acts_as_indexed :fields => [:title, :body]

  validates_presence_of :title
  validates_uniqueness_of :title

  has_friendly_id :title, :use_slug => true

  default_scope :order => "published_at DESC"
  
  if Rails.version < '3.0.0'
    named_scope :by_archive, lambda { |archive_date| {:conditions => ['published_at between ? and ?', archive_date.beginning_of_month, archive_date.end_of_month]} }
  else
    scope :by_archive, lambda { |archive_date|
      where ['published_at between ? and ?', archive_date.beginning_of_month, archive_date.end_of_month]
    }
  end
  
  if Rails.version < '3.0.0'
    named_scope :all_previous, :conditions => ['published_at <= ?', Time.now.beginning_of_month]
  else
    scope :all_previous, where(['published_at <= ?', Time.now.beginning_of_month])
  end

  if Rails.version < '3.0.0'
    named_scope :live, lambda { {:conditions => ["published_at < ? and draft = ?", Time.now, false]} }
  else
    scope :live, lambda { where( "published_at < ? and draft = ?", Time.now, false) }
  end
  
  def live?
    !draft and published_at <= Time.now
  end
  
  def category_ids=(ids)
    self.categories = ids.reject{|id| id.blank?}.collect {|c_id|
      BlogCategory.find(c_id.to_i) rescue nil
    }.compact
  end

  class << self
    def comments_allowed?
      RefinerySetting.find_or_set(:comments_allowed, true, {
        :scoping => :blog
      })
    end
  end
  
  module ShareThis
    DEFAULT_KEY = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    
    class << self
      def key
        RefinerySetting.find_or_set(:share_this_key, BlogPost::ShareThis::DEFAULT_KEY, {
          :scoping => :blog
        })
      end
      
      def enabled?
        key = BlogPost::ShareThis.key
        key.present? and key != BlogPost::ShareThis::DEFAULT_KEY
      end
    end
  end

end

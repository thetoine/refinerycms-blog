module BlogPostsHelper
  def blog_archive_list
    posts = BlogPost.select('published_at').all_previous
    return nil if posts.blank?
    html = '<section id="blog_archive_list"><h1>Archives</h1><nav>'
    links = []
    
    posts.each do |e|
      links << e.published_at.strftime('%m/%Y')
    end      
    links.uniq!
    links.each do |l|
      year = l.split('/')[1]
      month = l.split('/')[0]
      count = BlogPost.by_archive(Time.parse(l)).size
      text = "#{Date::MONTHNAMES[month.to_i]} #{year} (#{count})"
      html += link_to(text, archive_blog_posts_path(:year => year, :month => month))
    end
    html += '</nav></section>'
    html.html_safe
  end
end

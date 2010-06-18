# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def nl2br(string) 
     string.gsub("\n", '<br/>') 
  end
  
  def get_image(id)
      @photo = Photo.find(id)
      image_tag url_for_file_column(@photo, "image", "thumb")
  end
  

  
  def tag_cloud(tags, classes)
    max, min = 0, 0
    tags.each { |t|
      max = t.count.to_i if t.count.to_i > max
      min = t.count.to_i if t.count.to_i < min
    }

    divisor = ((max - min) / classes.size) + 1

    tags.each { |t|
      yield t.name, classes[(t.count.to_i - min) / divisor]
    }
  end
  
  def popular_cloud(tags, classes)
    max, min = 0, 0
    tags.each { |t|
      max = t.visit_count.to_i if t.visit_count.to_i > max
      min = t.visit_count.to_i if t.visit_count.to_i < min
    }

    divisor = ((max - min) / classes.size) + 1

    tags.each { |t|
      yield t.title, classes[(t.visit_count.to_i - min) / divisor]
    }
  end
  
  def pagination_links_remote(paginator)
    page_options = {:window_size => 1}
    pagination_links_each(paginator, page_options) do |n|
      options = {
        :url => {:action => 'list', :params => @params.merge({:page => n})},
        :update => 'table',
        :before => "Element.show('spinner')",
        :success => "Element.hide('spinner')"
      }
      html_options = {:href => url_for(:action => 'list', :params => @params.merge({:page => n}))}
      link_to_remote(n.to_s, options, html_options)
    end
  end
  
  
  
end

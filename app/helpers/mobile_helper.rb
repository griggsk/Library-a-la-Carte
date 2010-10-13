#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

module MobileHelper
  def truncate_description(search_result,search_term)
    data = get_column_name(search_result)
    if data.size > 0
     data = truncate_search(data, 100,search_term)#2nd parameter specifies the number of characters to truncate
    end
    return data
  end
  #determine which module was sent and return its topic,info, image_info or description data
  def get_column_name(search_result)
    if search_result[:topic]
      return search_result[:topic]
    elsif search_result[:information]
        return search_result[:information]
    elsif search_result[:info]
        return search_result[:info]
    elsif search_result[:image_info]
        return search_result[:image_info]
    elsif search_result[:description]
        return search_result[:description]
    else
      return ""
    end
    
  end
  
    #Truncates a given comment to the passed in size, without breaking words.
  def truncate_search(text, num_characters,search_term)
    text_copy = ""
    text_size = 0
    text = text.gsub(/<.*?>/, '')#remove html tags
    regex = Regexp.new('\b'+search_term+'\b',true)#create new regular expression that ignores case and only searches on word boundaries
    h(text).each(" ") do |w|
      w = w.gsub(regex,'<strong>' + w + '</strong>')#highlight the search word
      if text_size + w.size > num_characters
        break
      else
        text_size += w.size
        text_copy += " #{w}" 
      end
    end

      if num_characters < text_size
        text_copy = text_copy[0..(num_characters - 1)] + "..."
      elsif text.size > text_size
        text_copy += "..."
      end
    
    return text_copy.gsub("\n", '<br />')
  end
end

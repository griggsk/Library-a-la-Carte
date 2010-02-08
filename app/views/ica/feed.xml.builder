xml.instruct!
xml.rss("version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/") do
  xml.channel do
    xml.title @page_title
    xml.link @page_url
    xml.description @page_description
    xml.language 'en-us'
      for mod in @mods
        xml.item do
          xml.title mod.module_title
          xml.description mod.rss_content 
          xml.author @author_email
          xml.pubDate mod.updated_at.rfc822
          xml.link(@page_url)
          xml.guid(@page_url+"-"+mod.id.to_s)
        end
      end
  end
end
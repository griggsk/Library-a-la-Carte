xml.instruct! :xml, :version=>"1.0" ,:encoding=>"ISO8859-1"
xml.search_results do
  @search_results.each do |search_result|
    xml.module do
      xml.title(search_result[:module_title])
      xml.description(get_column_name(search_result))
    end
  end
end
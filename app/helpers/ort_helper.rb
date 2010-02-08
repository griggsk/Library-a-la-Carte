module OrtHelper
  
  def toc_link_to(name, options = {}, html_options = {})
  html_options.merge!({ :class => 'current' }) if current_page?(options)
  link_to name, options, html_options
end 
  
end

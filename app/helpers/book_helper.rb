module BookHelper
  
 if !@uses_tiny_mce.blank? 
  @tiny_mce_options[:theme] = "advanced"
end

end
##########################################################################
#
#ICAP Tool - Publishing System for and by librarians.
#Copyright (C) 2007 Oregon State University
#
#This file is part of the ICAP project.
#
#The ICAP project is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#Questions or comments on this program may be addressed to:
#ICAP - Library Technology
#121 The Valley Library
#Corvallis OR 97331-4501
#
#http://ica.library.oregonstate.edu/about/index.html
#
########################################################################

# Methods added to this helper will be available to all templates in the application.
#require 'recaptcha'
module ApplicationHelper
#include ReCaptcha::ViewHelper
include TagsHelper
  
 def show_mod(mod)
    if !mod.blank?
       @mod = mod
       mod_class = @mod.class.to_s
       render :partial => 'shared/'+mod_class.underscore+'_module',:object => @mod 
    end   
  end
  
  # Helper method that determines which form to show when editing a module.
# Determination is based on the mod_type parameter.
def show_form(mod_type)
     render :partial => 'module/'+mod_type.underscore+'_form'
end

 #adds css class to selected sort value 
  def sort_th_class_helper(param)
    result = "sortup" if @sort == param
    result = "sortdown" if @sort == param + "_reverse"
    return result
  end
  
#sorts list of my mods/guides/pages 
  def sort_link_helper(text, param)
  key = param
  key += "_reverse" if params[:sort] == param
  options = {
      :update => 'table',
      :loading => "Element.show('spinner_sort')",
      :complete => "Element.hide('spinner_sort')",
      :url => {:action => 'index',:params => params.merge({:sort => key, :page => nil})}
  }
  html_options = {
    :title => "Sort by this field",
    :href => url_for(:action => 'index', :params => params.merge({:sort => key, :page => nil}))
  }
  link_to_remote(text, options, html_options)
end

 
#database module sort a-z list
 def sort_links(sort)
   options = {
      :update => 'a_z_list',
      :loading => "Element.show('spinner_sort')",
      :complete => "Element.hide('spinner_sort')",
      :url => {:action => 'edit_databases', :params => params.merge({:sort => sort})}
  }
  html_options = {
    :title => "view databases the begin with this letter"
  }
  link_to_remote(sort, options, html_options)
 end
 
 def related_link
   options = {
      :update => 'suggestions',
      :loading => "Element.show('spinner_sort')",
      :complete => "Element.hide('spinner_sort')",
      :url => {:action => 'suggest_relateds'}
  }
  html_options = {
    :title => "Click to automatically find related guides"
  }
  link_to_remote("Automatically Add Related Guides", options, html_options)
 end

  #Truncates a given comment to the passed in size, without breaking words.
  #Additionally, converts newlines to html break tags, and will truncate
  #on a newline if the newline falls within the truncated length.
  #Finally, changes url's into clickable links.
  def truncate_comment(comment, num_characters)
    comment_copy = ""
    comment_size = 0

    h(comment).each(" ") do |w|
      if comment_size + w.size > num_characters
        break
      else
        comment_size += w.size
        w.sub!(/(http:\/\/.*?) /, '<a href="\1">\1</a> ')
        comment_copy += " #{w}" 
      end
    end

      first_newline = comment_copy[0..(num_characters - 1)].index("\n")

      if first_newline and comment.size != num_characters
        comment_copy = comment_copy[0..(first_newline - 1)] + "..."
      elsif comment.size > comment_size
        comment_copy += "..."
      end

    return comment_copy.gsub("\n", '<br />')
  end
  
 #helper method to get targets for library find modules
def checked?(val)
      targets = @mod.lf_targets.collect{|a| a.value}
      return  targets.include?(val)
end



def is_more?
   return  @mod.more_info.blank?
end
 
   
 def continue_link
    if @page
        link_to 'Edit Page', {:controller => 'page', :action => 'edit',  :id => @page}
   elsif @guide
        link_to 'Edit Guide', {:controller => 'guide', :action => 'edit',  :id => @guide}
   else
   end  
  end
   
end

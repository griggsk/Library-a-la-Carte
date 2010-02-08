module AdminHelper
  def next_master
        link_to_function image_tag("/images/icons/add.png", :title => 'Click to add a 1 more Master', :alt => '', :border => 0 )+" Add 1 more" do |page| 
          page.insert_html :bottom, :masters, :partial => 'master_form'
          page << "$('master_value').name = 'masters[' + $('formCount').value + '][value]'"
          page << "$('master_value').id = 'masters_' + $('formCount').value + '_value'"
          page << "$('formCount').value = (parseInt($('formCount').value) + 1)"
        end  
  end
  def next_subject
        link_to_function image_tag("/images/icons/add.png", :title => 'Click to add a 1 more Subject', :alt => '', :border => 0 )+" Add 1 More" do |page| 
          page.insert_html :bottom, :subjects, :partial => 'subject_form'
          page << "$('subject_subject_code').name = 'subjects[' + $('formCount').value + '][subject_code]'"
          page << "$('subject_subject_code').id = 'subjects_' + $('formCount').value + '_subject_code'"
          page << "$('subject_subject_name').name = 'subjects[' + $('formCount').value + '][subject_name]'"
          page << "$('subject_subject_name').id = 'subjects_' + $('formCount').value + '_subject_name'"
          page << "$('formCount').value = (parseInt($('formCount').value) + 1)"
        end  
  end
end
require 'find'

# Take a directory, and a list of patterns to match, and a list of
# filenames to avoid
def recursive_search(dir,patterns,
                     excludes=[/\.svn/, /,v$/, /\.cvs$/, /\.tmp$/,
                               /^RCS$/, /^SCCS$/])
  results = Hash.new{|h,k| h[k] = ''}

  Find.find(dir) do |path|
    fb =  File.basename(path) 
    next if excludes.any?{|e| fb =~ e}
    if File.directory?(path)
      if fb =~ /\.{1,2}/ 
        Find.prune
      else
        next
      end
    else  # file...
      File.open(path, 'r') do |f|
        ln = 1
        while (line = f.gets)
          patterns.each do |p|
            if line.include?(p)
              results[p] += "#{path}:#{ln}:#{line}"
            end
          end
          ln += 1
        end
      end
    end
  end
  return results
end

desc "Checks your app and gently warns you if you are using deprecated code."
task :deprecated => :environment do
  
  deprecated = {
    '@params'    => 'Use params[] instead',
    '@session'   => 'Use session[] instead',
    '@flash'     => 'Use flash[] instead',
    '@request'   => 'Use request[] instead',
    '@env' => 'Use env[] instead',
    'find_all\b'   => 'Use find(:all) instead',
    'find_first\b' => 'Use find(:first) instead',
    'render_partial' => 'Use render :partial instead',
    'component'  => 'Use of components are frowned upon',
    'paginate'   => 'The default paginator is slow. Writing your own may be faster',
    'start_form_tag'   => 'Use form_for instead',
    'end_form_tag'   => 'Use form_for instead',
    ':post => true'   => 'Use :method => :post instead'
  }

  results = recursive_search("#{File.expand_path('app', RAILS_ROOT)}",deprecated.keys)

  deprecated.each do |key, warning|
    puts '--> ' + key
    unless results[key] =~ /^$/
      puts "  !! " + warning + " !!"
      puts '  ' + '.' * (warning.length + 6)
      puts results[key]
    else
      puts "  Clean! Cheers for you!"
    end
    puts
  end

end

#namespace 'views' do
  desc 'Renames all .rhtml views to .html.erb, .rjs to .js.rjs, .rxml to .xml.builder, and .haml to .html.haml'
 task :rename do
 # task 'rename' do
    Dir.glob('app/views/**/*.rhtml').each do |file|
      puts `svn mv #{file} #{file.gsub(/\.rhtml$/, '.html.erb')}`
    end

    Dir.glob('app/views/**/[^_]*.rxml').each do |file|
      puts `svn mv #{file} #{file.gsub(/\.rxml$/, '.xml.builder')}`
      
    end

    Dir.glob('app/views/**/[^_]*.rjs').each do |file|
      puts `svn mv #{file} #{file.gsub(/\.rjs$/, '.js.rjs')}`
    end
    Dir.glob('app/views/**/[^_]*.haml').each do |file|
      puts `svn mv #{file} #{file.gsub(/\.haml$/, '.html.haml')}`
    end
  end


desc 'Creates sql insert commands for previously uploaded images to add them to the image manager.'
    task :move_to_image_manager => :environment do
      puts "\nThis rake task creates sql insert commands to move previously uploaded images into the image manager.\n"
      puts "The insert commands are added to the file \/db\/image_manager_update.sql\n"
      puts "After the rake task is complete, run the image_manager_update.sql file in your database tool\n"
      base_path = ENV["DIR"] || "db"     
      db_config = ActiveRecord::Base.configurations[RAILS_ENV]   
      tempSQL = RAILS_ROOT + '/db/image_manager_update.sql'

      #First an array is setup and all of the previously uploaded image paths
      #are stored in it.
      paths=[]
      Dir.glob('public/photos/photos/original/*.jpg').each do |image_path|
        paths << image_path 
      end
      Dir.glob('public/photos/photos/original/*.png').each do |image_path|
        paths << image_path 
      end
      Dir.glob('public/photos/photos/original/*.bmp').each do |image_path|
        paths << image_path 
      end
      Dir.glob('public/photos/photos/original/*.gif').each do |image_path|
        paths << image_path 
      end
      Dir.glob('public/photos/photos/original/*.jpeg').each do |image_path|
        paths << image_path 
      end
      Dir.glob('public/photos/photos/original/*.pjpeg').each do |image_path| 
        paths << image_path 
      end
      Dir.glob('public/photos/photos/original/*.x-png').each do |image_path|
        paths << image_path 
      end
     
      i=0
      paths.each do |path|
        fname = path.gsub(/public\/photos\/photos\/original\//,"")
        type = (path.match(/\.(\w+)$/)[1] rescue "octet-stream").downcase
        fsize = File.size?(path).to_s
        newstr = "INSERT INTO image_managers (photo_file_name,created_at,updated_at,photo_updated_at,photo_content_type,photo_file_size) Values ('#{fname}',now(),now(),now(),'#{type}',#{fsize});"
        if i > 0 
         f = File.open(tempSQL,'a')
        else #overwrite an existing copy of image_manager_update.sql
         f = File.open(tempSQL,'w')
        end
        f.puts(newstr)
        f.close   
        i+=1
      end
      
      puts "\nThe SQL commands have been added to \/db\/image_manager_update.sql\n"
    end
    
desc 'This task moves the resources in style_resources, recom_resources, plag_resources, and assign_resources
      to miscellaneous_resources table and changes the matching entry in the resources table to reflect the new
      id in miscellaneous_resources'
  task :resource_transfer => :environment do
    ################ Style Resource ################################

    style_resources = StyleResource.find(:all) 
    
    #loop through all of the Style_Resource table entries
    style_resources.each do |style_resource|
      resource_query = Resource.find(:first,:conditions => "mod_id ='#{style_resource.id}' AND mod_type = 'StyleResource'")
      if !resource_query.nil? #ignore style_resources without corresponding resource entries
        new_misc_resource = MiscellaneousResource.new(:module_title => style_resource.module_title, 
                                                      :label => style_resource.label,:content => style_resource.information,
                                                      :updated_at => style_resource.updated_at,:global => style_resource.global,
                                                      :created_by => style_resource.created_by)
        #if the new miscellaneous resource was saved, continue on, otherwise, stop
        if new_misc_resource.save
          #find a match where mod_id in resources = the id in style_resource and update this entry 
          #with the newly created misc resource data
         
          resource_query.update_attributes(:mod_id => new_misc_resource.id,:mod_type => 'MiscellaneousResource')
          if resource_query.save
            puts "## Style_Resource - Saved new Miscellanous Resource #{new_misc_resource.id} and updated Resource id #{resource_query.id} ##"   
          else
            puts "############ Failed to update Resource #{resource_query.id} ###########" 
          end
        else
          puts "############ Failed to save new Miscellanous Resource #{new_misc_resource.id} ###########" 
        end
      end
    end
    
    ########################### Recom_Resource #############################################
    
    recom_resources = RecomResource.find(:all) 
    
    #loop through all of the Style_Resource table entries
    recom_resources.each do |recom_resource|
      resource_query = Resource.find(:first,:conditions => "mod_id ='#{recom_resource.id}' AND mod_type = 'RecomResource'")
      if !resource_query.nil? #ignore style_resources without corresponding resource entries
        new_misc_resource = MiscellaneousResource.new(:module_title => recom_resource.module_title, 
                                                      :label => recom_resource.label,:content => recom_resource.recommendations,
                                                      :updated_at => recom_resource.updated_at,:global => recom_resource.global,
                                                      :created_by => recom_resource.created_by)
        #if the new miscellaneous resource was saved, continue on, otherwise, stop
        if new_misc_resource.save
          #find a match where mod_id in resources = the id in recom_resource and update this entry 
          #with the newly created misc resource data
          
          resource_query.update_attributes(:mod_id => new_misc_resource.id,:mod_type => 'MiscellaneousResource')
          if resource_query.save
            puts "## Recom_Resource - Saved new Miscellanous Resource #{new_misc_resource.id} and updated Resource id #{resource_query.id} ##"   
          else
            puts "############ Failed to update Resource #{resource_query.id} ###########" 
          end
        else
          puts "############ Failed to save new Miscellanous Resource #{new_misc_resource.id} ###########" 
        end
      end
    end
    
    ########################### Assign_Resource #############################################
    
    assign_resources = AssignResource.find(:all) 
    
    #loop through all of the Style_Resource table entries
    assign_resources.each do |assign_resource|
      resource_query = Resource.find(:first,:conditions => "mod_id ='#{assign_resource.id}' AND mod_type = 'AssignResource'")
      if !resource_query.nil? #ignore style_resources without corresponding resource entries
        new_misc_resource = MiscellaneousResource.new(:module_title => assign_resource.module_title, 
                                                      :label => assign_resource.label,:content => assign_resource.description,
                                                      :updated_at => assign_resource.updated_at,:global => assign_resource.global,
                                                      :created_by => assign_resource.created_by)
        #if the new miscellaneous resource was saved, continue on, otherwise, stop
        if new_misc_resource.save
          #find a match where mod_id in resources = the id in assign_resource and update this entry 
          #with the newly created misc resource data
          
          resource_query.update_attributes(:mod_id => new_misc_resource.id,:mod_type => 'MiscellaneousResource')
          if resource_query.save
            puts "## Assign_Resource - Saved new Miscellanous Resource #{new_misc_resource.id} and updated Resource id #{resource_query.id} ##"   
          else
            puts "############ Failed to update Resource #{resource_query.id} ###########" 
          end
        else
          puts "############ Failed to save new Miscellanous Resource #{new_misc_resource.id} ###########" 
        end
      end
    end
    
    ########################### Plag_Resource #############################################
    
    plag_resources = PlagResource.find(:all) 
    
    #loop through all of the Style_Resource table entries
    plag_resources.each do |plag_resource|
      resource_query = Resource.find(:first,:conditions => "mod_id ='#{plag_resource.id}' AND mod_type = 'PlagResource'")
      if !resource_query.nil? #ignore style_resources without corresponding resource entries
        new_misc_resource = MiscellaneousResource.new(:module_title => plag_resource.module_title, 
                                                      :label => plag_resource.label,:content => plag_resource.information,
                                                      :updated_at => plag_resource.updated_at,:global => plag_resource.global,
                                                      :created_by => plag_resource.created_by)
        #if the new miscellaneous resource was saved, continue on, otherwise, stop
        if new_misc_resource.save
          #find a match where mod_id in resources = the id in plag_resource and update this entry 
          #with the newly created misc resource data
          
          resource_query.update_attributes(:mod_id => new_misc_resource.id,:mod_type => 'MiscellaneousResource')
          if resource_query.save
            puts "## Plag_Resource - Saved new Miscellanous Resource #{new_misc_resource.id} and updated Resource id #{resource_query.id} ##"   
          else
            puts "############ Failed to update Resource #{resource_query.id} ###########" 
          end
        else
          puts "############ Failed to save new Miscellanous Resource #{new_misc_resource.id} ###########" 
        end
      end
    end
  end

desc 'This task initializes the types and guides fields in the locals table.  This task needs to be run when
      updating from version 1.3 to version 1.4'
  task :locals_update => :environment do
    local = Local.find(:first)
    local.initialize_types
    if local.save
      puts "Types and Guides have been initialized in locals"
    else
      puts "Types and Guides failed to initialize in locals"
    end
  end
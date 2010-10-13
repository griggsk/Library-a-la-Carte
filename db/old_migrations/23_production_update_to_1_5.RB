class ProductionUpdateTo15 < ActiveRecord::Migration
  def self.up
    add_column :answers, :feedback,:text
    BookResource.update_all({:slug => ''},{:slug => nil})
    change_column :book_resources, :slug , :string 
    change_column :book_resources,:label,:string
    change_column :book_resources,:content_type,:string,:default => "Books"
    add_column :books, :position, :integer 
    change_column :comment_resources,:module_title,:string,:default => "",:null => false
    change_column :comment_resources, :slug , :string
    remove_index :comments,:name => "comment_resource_id"
    add_index :comments, [:author_email, :created_at], :name => "author_email"
    change_column :course_widgets, :slug , :string 
    change_column :database_resources,:slug,:string
    change_column :feeds,:label,:string,:null => false
    remove_index :guides, :name => "published"
    add_index :guides,:resource_id, :name => "resource_id"
    add_column :guides,:relateds,:text
    change_column :image_resources,:slug,:string
    change_column :image_resources,:size,:string,:default => "F"
    change_column :image_resources,:orientation,:string,:default => "V"
    add_column :images,:position,:integer
    change_column :inst_resources,:module_title,:string,:default => ""
    change_column :inst_resources,:slug,:string 
    remove_column :inst_resources,:phone_num
    change_column :lib_resources,:slug,:string
    change_column :lib_resources,:module_title,:string,:default => ""
    change_column :libfind_resources,:slug,:string
    change_column :links,:url,:string
    add_column :links,:position,:integer   
    remove_index :lf_targets,:name => "libfind_resource_id"
    change_column :locals,:proxy,:string
    change_column :locals,:banner_url,:string
    change_column :locals,:logo_url,:string
    change_column :locals,:lib_url,:string
    change_column :locals,:styles,:string
    change_column :locals,:lib_url,:string 
    change_column :locals,:univ_url,:string
    add_column :locals,:left_box,:text
    add_column :locals,:js_link,:string
    add_column :locals,:meta,:text
    add_column :locals,:tracking,:text
    add_column :locals,:site_search_label,:string
    add_column :locals,:book_search_label,:string    
    add_column :locals,:guide_box,:text
    add_column :locals,:right_box,:text     
    remove_column :locals,:link_one,:link_two,:link_three,:name_one,:name_two,:name_three,:lib_help,:lib_chat
    remove_index :masters, :name => "value"
    change_column :miscellaneous_resources,:module_title,:string,:default => ""
    change_column :miscellaneous_resources,:slug,:string
    change_column :pages,:term,:string
    change_column :pages,:year,:string
    change_column :pages,:course_num,:string
    remove_index :pages, :name => "archived"
    remove_index :pages, :name => "published"   
    change_column :questions,:updated_at,:datetime,:null => false
    change_column :questions,:points,:integer,:default => 0,:null => false
    change_column :quiz_resources,:created_by,:string
    change_column :quiz_resources,:global,:integer,:limit => 1,:default => 0
    change_column :quiz_resources,:slug,:string
    change_column :quiz_resources,:content_type,:string,:default => "Quiz",:null => false
    change_column :reserve_resources,:module_title,:string,:default => ""
    change_column :reserve_resources,:slug,:string
    remove_index :resources,:name => 'mod_id'
    remove_index :results,:name => "student_id_2"
    add_index :results,:student_id, :name => "student_id"
    change_column :rss_resources,:module_title,:string,:default => ""
    change_column :rss_resources,:slug,:string
    change_column :rss_resources,:label,:string
    change_column :rss_resources,:topic,:string,:null => false
    change_column :rss_resources,:style,:string,:default => "mixed",:null => false
    change_column :students,:onid,:string,:null => false
    change_column :students,:sect_num,:string
    remove_index :students,:name => 'tutorial_id'
    add_index :subjects, :subject_code
    add_index :subjects, :subject_name
    remove_index :subjects, :name => "index_subjects_on_subject_code"
    remove_index :subjects, :name => "subject_code"
    remove_index :subjects, :name => "index_subjects_on_subject_name"
    remove_index :subjects, :name => "subject_name"    
    add_column :tabs,:tabable_id,:integer
    add_column :tabs,:tabable_type,:string
    add_index :tabs,["tabable_id", "tabable_type"]
    #####guides######
    Tab.update_all("tabable_id = guide_id,tabable_type = 'Guide'", "guide_id > 0")
    #####pages######
    Tab.update_all("tabable_id = page_id,tabable_type = 'Page'", "page_id > 0")
    remove_column :tabs,:guide_id
    execute("alter table tabs drop foreign key tabs_ibfk_1;")
    remove_column :tabs,:page_id
    remove_index :tabs,:name => "position"
    remove_index :tags,:name => "name"
    add_index :tutorials, :created_by
    change_column :units,:slug,:string,:null => false
    remove_index :uploadables, :name => "uploader_resource_id"
    add_index :uploadables, ["id", "uploader_resource_id"]
    change_column :uploader_resources,:module_title,:string,:default => "Course Materials"
    change_column :uploader_resources,:slug,:string
    change_column :url_resources,:module_title,:string,:default => ""
    change_column :url_resources,:slug,:string
    change_column :url_resources,:label,:string
    change_column :users,:name,:string,:null => false
    change_column :users,:hashed_psswrd,:string,:null => false
    change_column :users,:email,:string,:null => false
    change_column :users,:salt,:string,:null => false
    change_column :users,:role,:string,:default => "author", :null => false
    change_column :video_resources,:module_title,:string
    change_column :video_resources,:slug,:string
    add_column :video_resources,:size,:string,:default => "F"
    add_column :video_resources,:orientation,:string,:default => "V"  
    change_column :video_resources,:content_type,:string,:default => "Videos"
    add_column :videos,:position,:integer
  end

  def self.down
    remove_column :videos,:position
    change_column :video_resources,:content_type,:string,:default => "YouTube Videos"
    change_column :video_resources,:module_title,:string,:default => "",:null => false
    remove_column :video_resources,:orientation
    remove_column :video_resources,:size
    change_column :video_resources,:slug,:string,:limit => 25
    change_column :users,:role,:string,:default => "author", :null => false,:limit => 55
    change_column :users,:salt,:string,:null => false,:default => ""
    change_column :users,:email,:string,:null => false,:default => ""
    change_column :users,:hashed_psswrd,:string,:null => false,:default => ""
    change_column :users,:name,:string,:null => false,:default => ""
    change_column :url_resources,:module_title,:string,:limit => 55,:default => "",:null => false
    change_column :url_resources,:slug,:string,:limit => 25
    change_column :url_resources,:label,:string,:limit => 55
    change_column :uploader_resources,:module_title,:string,:limit => 55,:default => "",:null => false
    change_column :uploader_resources,:slug,:string,:limit => 25
    remove_index :uploadables, ["id", "uploader_resource_id"]
    add_index :uploadables, :uploader_resource_id, :name => "uploader_resource_id"
    change_column :units,:slug,:string,:null => false,:limit => 15
    remove_index :tutorials, :created_by
    add_index :tags, :name,:name => "name"
    remove_index :tabs,["tabable_id", "tabable_type"]
    add_column :tabs,:guide_id,:integer
    add_column :tabs,:page_id,:integer
    execute "UPDATE tabs SET guide_id = tabable_id WHERE tabable_id > 0 AND tabable_type='Guide';"
    execute "UPDATE tabs SET page_id = tabable_id WHERE tabable_id > 0 AND tabable_type='Page';"
    remove_column :tabs,:tabable_type
    remove_column :tabs,:tabable_id
    add_index :tabs, :guide_id, :name => "guide_id"
    add_index :tabs, :page_id, :name => "page_id"
    add_index :tabs,:position, :name => "position"
    execute("ALTER TABLE `tabs` ADD CONSTRAINT `tabs_ibfk_1` FOREIGN KEY (`page_id`) REFERENCES `pages` (`id`);")
    add_index :subjects, :subject_code, :name => "subject_code"
    add_index :subjects, :subject_name, :name => "subject_name"
    change_column :students,:onid,:string,:limit => 55,:null => false
    change_column :students,:sect_num,:string,:limit => 55
    add_index :students, :tutorial_id, :name => "tutorial_id"
    change_column :rss_resources,:slug,:string,:limit => 25
    change_column :rss_resources,:module_title,:string,:limit => 55,:default => "",:null => false
    change_column :rss_resources,:label,:string,:limit => 55
    change_column :rss_resources,:topic,:string,:limit => 100,:null => false
    change_column :rss_resources,:style,:string,:limit => 55,:default => "mixed",:null => false
    remove_index :results,:name => "student_id"
    add_index :results, [:student_id, :question_id],:name => "student_id_2", :unique => true
    add_index :resources, [:mod_id, :mod_type], :name => "mod_id"
    change_column :reserve_resources,:slug,:string,:limit => 25
    change_column :reserve_resources,:module_title,:string,:limit => 55,:default => "",:null => false
    change_column :quiz_resources,:created_by,:string
    change_column :quiz_resources,:global,:integer,:null => false,:default => 0
    change_column :quiz_resources,:slug,:string,:limit => 25
    change_column :quiz_resources,:content_type,:string,:limit => 55,:default => "Quiz",:null => false
    change_column :questions,:updated_at,:datetime
    change_column :pages,:term,:string,:default => "",:null => false
    change_column :pages,:year,:string,:default => "",:null => false
    change_column :pages,:course_num,:string,:limit => 55
    add_index :pages, [:archived],:name => "archived"
    add_index :pages, [:published],:name => "published"
    change_column :miscellaneous_resources,:module_title,:string,:default => "",:null => false
    change_column :miscellaneous_resources,:slug,:string,:limit => 25
    add_index :masters, [:value], :name => "value"
    remove_column :locals,:left_box,:js_link,:meta,:tracking,:site_search_label,:book_search_label,:guide_box,:right_box
    change_column :locals,:univ_url,:string
    change_column :locals,:proxy,:string,:limit => 500
    change_column :locals,:lib_url,:string
    change_column :locals,:styles,:string
    change_column :locals,:lib_url,:string
    change_column :locals,:banner_url,:string,:limit => 555
    change_column :locals,:logo_url,:string,:limit => 555
    change_column :locals,:styles,:text
    add_column :locals,:link_one,:string
    add_column :locals,:link_two,:string
    add_column :locals,:link_three,:string
    add_column :locals,:name_one,:string
    add_column :locals,:name_two,:string
    add_column :locals,:name_three,:string
    add_column :locals,:lib_help,:string
    add_column :locals,:lib_chat,:text
    remove_column :links,:position
    change_column :links,:url,:string
    change_column :libfind_resources,:slug,:string
    change_column :lib_resources,:module_title,:string,:default => "",:limit => 55
    change_column :lib_resources,:slug,:string,:limit => 25
    change_column :libfind_resources,:slug,:string,:limit => 25
    add_index :lf_targets, [:libfind_resource_id], :name => "libfind_resource_id"
    change_column :inst_resources,:module_title,:string,:limit => 55,:default => "",:null => false
    change_column :inst_resources,:slug,:string,:limit => 25 
    add_column :inst_resources,:phone_num,:string
    remove_column :images,:position
    change_column :image_resources,:slug,:string,:limit => 25
    change_column :image_resources,:size,:string,:default => "F",:limit => 5
    change_column :image_resources,:orientation,:string,:default => "V",:limit => 5
    add_index :guides, [:published], :name => "published"
    remove_index :guides,:name => "resource_id"
    remove_column :guides,:relateds
    change_column :feeds,:label,:string,:limit => 55
    change_column :database_resources,:slug,:string,:limit => 25
    change_column :course_widgets, :slug , :string,:limit => 25
    change_column :comment_resources,:module_title,:string,:default => "Comments", :null => false
    change_column :comment_resources, :slug,:string,:limit => 25
    add_index :comments, [:comment_resource_id], :name => "comment_resource_id"
    remove_index :comments, :name => "author_email"    
    remove_column :books, :position
    change_column :book_resources, :slug ,:string,:limit => 25
    change_column :book_resources,:label,:string,:limit => 55
    change_column :book_resources,:content_type,:string,:default => "Catalog Links"    
    remove_column :answers, :feedback
  end
end

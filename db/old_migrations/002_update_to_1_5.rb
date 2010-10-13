class UpdateTo15 < ActiveRecord::Migration
  def self.up
    add_column :answers, :feedback,:text
    change_column :answers,:correct,:boolean,:default => false
    add_column :book_resources, :slug , :string 
    add_column :book_resources, :published, :boolean,:default => false
    change_column :book_resources, :module_title, :string,:null => false
    change_column :book_resources,:global,:boolean,:default => false
    add_column :books, :location, :boolean , :default => true
    add_column :books, :position, :integer 
    change_column :books, :image_id,:string
    change_column :comment_resources,:num_displayed,:integer,:default => 3
    change_column :comment_resources,:global,:boolean,:default => false
    change_column :comment_resources,:module_title,:string,:null => false
    add_column :comment_resources, :slug , :string 
    add_column :comment_resources, :published, :boolean,:default => false
    change_column :course_widgets,:module_title,:string,:null => false  
    add_column :course_widgets, :slug , :string
    add_column :course_widgets, :published, :boolean,:default => false   
    change_column :course_widgets, :global, :boolean,:default => false
    change_column :database_dods,:database_resource_id,:integer,:null => false
    change_column :database_dods,:dod_id,:integer,:null => false 
    change_column :database_resources,:module_title,:string,:null => false
    change_column :database_resources,:global,:boolean,  :default => false
    change_column :database_resources,:content_type,:string, :default => "Databases"
    add_column :database_resources,:slug,:string
    add_column :database_resources,:published,:boolean,:default => false
    change_column :dods,:url,:string,:null => false
    change_column :dods,:proxy,:boolean,:default => false
    change_column :dods,:title,:string,:null => false
    change_column :dods,:url,:string,:null => false
    change_column :dods,:startdate,:string,:default => "unknown"
    change_column :dods,:enddate,:string,:default => "unknown"
    change_column :dods,:provider,:string,:null => false
    change_column :feeds,:label,:string,:null => false
    change_column :feeds,:url,:string,:null => false
    change_column :feeds,:rss_resource_id,:integer, :null => false
    add_column :guides,:relateds,:text
    change_column :guides,:created_by,:string,:null => true
    change_column :guides,:published,:boolean,:default => false,:null => true
    change_column :image_resources,:module_title,:string, :null => false
    change_column :image_resources,:content_type,:string,:default => "Images"
    add_column :image_resources,:slug,:string
    add_column :image_resources,:size,:string,  :default => "F"
    add_column :image_resources,:orientation,:string,:default => "V"
    add_column :image_resources,:published,:boolean,:default => false
    change_column :image_resources,:global,:boolean,:default => false
    add_column :images,:position,:integer
    change_column :inst_resources,:module_title,:string,:null => false
    change_column :inst_resources,:global,:boolean,:default => false
    add_column :inst_resources,:slug,:string 
    add_column :inst_resources,:published,:boolean,:default => false
    drop_table :lf_targets
    change_column :lib_resources,:module_title,:string,:null => false
    change_column :lib_resources,:global,:boolean,:default => false
    add_column :lib_resources,:slug,:string
    add_column :lib_resources,:published,:boolean,:default => false
    drop_table :libfind_resources 
    change_column :links,:url,:string
    add_column :links,:target,:boolean,:default => false
    add_column :links,:position,:integer   
    change_column :locals,:banner_url,:string
    change_column :locals,:logo_url,:string
    change_column :locals,:lib_url,:string
    change_column :locals,:proxy,:string
    add_column :locals,:admin_email_to,:string
    add_column :locals,:admin_email_from,:string
    change_column :locals,:styles,:string
    change_column :locals,:univ_url,:string  
    add_column :locals,:left_box,:text
    add_column :locals,:js_link,:string
    add_column :locals,:meta,:text
    add_column :locals,:tracking,:text
    add_column :locals,:site_search_label,:string
    add_column :locals,:book_search_label,:string
    add_column :locals,:guide_box,:text
    add_column :locals,:right_box,:text  
    add_column :locals,:enable_search,:boolean,:default => true
    remove_column :locals,:link_one
    remove_column :locals,:link_two
    remove_column :locals,:link_three
    remove_column :locals,:name_one
    remove_column :locals,:name_two
    remove_column :locals,:name_three
    remove_column :locals,:lib_help
    remove_column :locals,:lib_chat   
    change_column :masters,:value,:string,:null => false
    change_column :miscellaneous_resources,:module_title,:string, :null => false
    change_column :miscellaneous_resources,:global,:boolean,:default => false
    add_column :miscellaneous_resources,:slug,:string
    add_column :miscellaneous_resources,:published,:boolean,:default => false 
    change_column :pages,:course_name,:string,:null => false
    change_column :pages,:course_num,:string
    change_column :pages,:archived,:boolean,:default => false
    change_column :pages,:published,:boolean,:default => false,:null => true
    change_column :questions,:q_type,:string,:default => "MC",:null => true
    change_column :questions,:points,:integer,:default => 0
    change_column :questions,:updated_at,:datetime,:null => true
    change_column :quiz_resources,:module_title,:string,:null => false
    change_column :quiz_resources,:created_by,:string
    change_column :quiz_resources,:content_type,:string,:default => "Quiz"
    change_column :quiz_resources,:global,:boolean,:default => false
    change_column :quiz_resources,:graded,:boolean,:default => false
    add_column :quiz_resources,:published,:boolean,:default => false
    add_column :quiz_resources,:slug,:string
    change_column :reserve_resources,:module_title,:string,:null => false
    change_column :reserve_resources,:global,:boolean,:default => false
    add_column :reserve_resources,:slug,:string
    add_column :reserve_resources,:published,:boolean,:default => false
    change_column :resourceables,:position,:integer,:null => true
    change_column :results,:score,:integer,:default => 0
    add_column :results,:position,:integer
    change_column :rss_resources,:module_title,:string,:null => false
    change_column :rss_resources,:num_feeds,:integer,:default => 6
    change_column :rss_resources,:module_title,:string
    change_column :rss_resources,:global,:boolean,:default => false
    RssResource.update_all({:topic => ''},{:topic => nil})
    change_column :rss_resources,:topic,:string
    change_column :rss_resources,:style,:string,:default => "mixed"
    add_column :rss_resources,:slug,:string
    add_column :rss_resources,:published,:boolean,:default => false
    remove_column :students,:name
    add_column :students,:firstname,:string
    add_column :students,:lastname,:string
    change_column :students,:onid,:string,:null => true
    change_column :students,:sect_num,:string
    change_column :students,:email,:string,:null => true
    change_column :subjects,:subject_code,:string,:null => true
    change_column :subjects,:subject_name,:string,:null => true
    add_column :tabs,:tabable_id,:integer
    add_column :tabs,:tabable_type,:string
    change_column :tabs,:tab_name,:string
    add_index :tabs,["tabable_id", "tabable_type"]
    #####guides######
    Tab.update_all("tabable_id = guide_id,tabable_type = 'Guide'", "guide_id > 0")
    #####pages######
    Tab.update_all("tabable_id = page_id,tabable_type = 'Page'", "page_id > 0")
    remove_column :tabs,:guide_id
    remove_column :tabs,:page_id
    change_column :tutorials,:name,:string    
    change_column :tutorials,:graded,:boolean,:default => false
    change_column :tutorials,:published,:boolean,:default => false,:null => true
    change_column :tutorials,:archived,:boolean,:default => false,:null => true
    change_column :tutorials,:course_num,:string
    change_column :tutorials,:pass,:string,:default => "p@ssword",:null => true
    change_column :units,:title,:string,:null => false
    add_column :units,:slug,:string
    change_column :uploader_resources,:module_title,:string,:null => false
    change_column :uploader_resources,:global,:boolean,:default => false
    add_column :uploader_resources,:slug,:string
    add_column :uploader_resources,:published,:boolean,:default => false
    change_column :url_resources,:module_title,:string,:null => false
    add_column :url_resources,:slug,:string
    add_column :url_resources,:published,:boolean,:default => false
    change_column :url_resources,:global,:boolean,:default => false
    change_column :users,:name,:string,:null => false,:default => nil
    change_column :users,:hashed_psswrd,:string,:null => false,:default => nil
    change_column :users,:email,:string,:null => false,:default => nil
    change_column :users,:salt,:string,:null => false,:default => nil
    change_column :video_resources,:module_title,:string,:null => false
    add_column :video_resources,:slug,:string
    add_column :video_resources,:published,:boolean,:default => false
    add_column :video_resources,:size,:string,:default => "F"
    add_column :video_resources,:orientation,:string,:default => "V"  
    change_column :video_resources,:global,:boolean,:default => false
    add_column :videos,:position,:integer
  end

  def self.down
    remove_column :videos,:position
    change_column :video_resources,:global,:integer,:default => 0
    remove_column :video_resources,:orientation
    remove_column :video_resources,:size
    remove_column :video_resources,:published
    remove_column :video_resources,:slug
    change_column :video_resources,:module_title,:string
    change_column :users,:salt,:string,:null => false,:default => ""
    change_column :users,:email,:string,:null => false,:default => ""
    change_column :users,:hashed_psswrd,:string,:null => false,:default => ""
    change_column :users,:name,:string,:null => false,:default => ""
    change_column :url_resources,:global,:integer,:default => 0
    remove_column :url_resources,:published
    remove_column :url_resources,:slug
    change_column :url_resources,:module_title,:string
    remove_column :uploader_resources,:published
    remove_column :uploader_resources,:slug
    change_column :uploader_resources,:global,:integer,:default => 0
    change_column :uploader_resources,:module_title,:string
    remove_column :units,:slug
    change_column :units,:title,:string,:null => false,:default => ""
    change_column :tutorials,:pass,:string, :default => "Ken Kesey", :null => false
    change_column :tutorials,:course_num,:string
    change_column :tutorials,:archived,:integer,:default => 0,:null => false
    change_column :tutorials,:published,:integer,:default => 0,:null => false
    change_column :tutorials,:graded,:integer,:default => 0
    change_column :tutorials,:name,:string,:default => "",:null => false
    remove_index :tabs,["tabable_id", "tabable_type"]
    add_column :tabs,:guide_id,:integer
    add_column :tabs,:page_id,:integer
    execute "UPDATE tabs SET guide_id = tabable_id WHERE tabable_id > 0 AND tabable_type='Guide';"
    execute "UPDATE tabs SET page_id = tabable_id WHERE tabable_id > 0 AND tabable_type='Page';"
    remove_column :tabs,:tabable_type
    remove_column :tabs,:tabable_id
    add_index :tabs, :guide_id, :name => "guide_id"
    add_index :tabs, :page_id, :name => "page_id"
    change_column :tabs,:tab_name,:string,:limit => 20
    change_column :subjects,:subject_name,:string, :null => false,:default => ""
    change_column :subjects,:subject_code,:string, :null => false,:default => ""
    change_column :students,:email,:string,:default => "",:null => false
    change_column :students,:sect_num,:string
    change_column :students,:onid,:string,:default => "",:null => false
    remove_column :students,:lastname
    remove_column :students,:firstname
    add_column :students,:name,:string, :null => false
    change_column :rss_resources,:module_title,:string
    remove_column :rss_resources,:slug
    remove_column :rss_resources,:published    
    change_column :rss_resources,:style,:string,:default => "mixed"
    change_column :rss_resources,:topic,:string 
    change_column :rss_resources,:global,:integer,:default => 0
    change_column :rss_resources,:module_title,:string
    change_column :rss_resources,:num_feeds,:integer,:default => 6
    remove_column :results,:position
    change_column :results,:score,:integer,:default => 0
    change_column :resourceables,:position,:integer,:null => false
    remove_column :reserve_resources,:slug
    remove_column :reserve_resources,:published
    change_column :reserve_resources,:global,:integer,:default => 0
    change_column :reserve_resources,:module_title,:string
    remove_column :quiz_resources,:slug
    remove_column :quiz_resources,:published
    change_column :quiz_resources,:graded,:integer,:default => 0
    change_column :quiz_resources,:content_type,:string,:default => "Quiz"
    change_column :quiz_resources,:created_by,:string
    change_column :quiz_resources,:module_title,:string
    change_column :questions,:points,:integer,:default => 0,:null => false
    change_column :questions,:q_type,:string,:default => "MC",:null => false
    change_column :questions,:updated_at,:datetime,:null => false
    change_column :pages,:archived,:integer,:default => 0,:limit => 1
    change_column :pages,:course_num,:string
    change_column :pages,:course_name,:string
    change_column :pages,:published,:boolean,:default => false, :null => false
    remove_column :miscellaneous_resources,:published 
    remove_column :miscellaneous_resources,:slug
    change_column :miscellaneous_resources,:global,:integer,:default => 0
    change_column :miscellaneous_resources,:module_title,:string
    change_column :masters,:value,:string
    remove_column :locals,:admin_email_from
    remove_column :locals,:admin_email_to
    change_column :locals,:proxy,:string
    change_column :locals,:lib_url,:string
    change_column :locals,:logo_url,:string
    change_column :locals,:banner_url,:string
    change_column :locals,:styles,:string
    change_column :locals,:univ_url,:string
    add_column :locals,:link_one,:string
    add_column :locals,:link_two,:string
    add_column :locals,:link_three,:string
    add_column :locals,:name_one,:string
    add_column :locals,:name_two,:string
    add_column :locals,:name_three,:string
    add_column :locals,:lib_help,:string
    add_column :locals,:lib_chat,:text
    remove_column :locals,:enable_search
    remove_column :locals,:left_box
    remove_column :locals,:js_link
    remove_column :locals,:meta    
    remove_column :locals,:tracking
    remove_column :locals,:site_search_label
    remove_column :locals,:book_search_label
    remove_column :locals,:guide_box
    remove_column :locals,:right_box   
    remove_column :links,:position
    remove_column :links,:target
    change_column :links,:url,:string
    create_table "libfind_resources", :force => true do |t|
      t.string   "module_title",:default => "",:null => false
      t.string   "label"
      t.text     "information"
      t.datetime "updated_at"
      t.string   "content_type",:default => "LibraryFind Search"
      t.boolean  "global",:default => false
      t.string   "created_by"
      t.string   "slug"
      t.boolean  "published",:default => false
    end
    remove_column :lib_resources,:published
    remove_column :lib_resources,:slug
    change_column :lib_resources,:global,:integer,:default => 0
    change_column :lib_resources,:module_title,:string
    create_table :lf_targets do |t|
      t.integer "libfind_resource_id"
      t.string  "value"      
    end
    remove_column :inst_resources,:published
    remove_column :inst_resources,:slug
    change_column :inst_resources,:global,:integer,:default => 0
    change_column :inst_resources,:module_title,:string
    remove_column :images,:position
    remove_column :image_resources,:published
    change_column :image_resources,:module_title,:string
    remove_column :image_resources,:orientation
    remove_column :image_resources,:size
    remove_column :image_resources,:slug
    change_column :image_resources,:global,:integer,:default => 0
    change_column :image_resources,:content_type,:string,:default => "Images"
    change_column :guides,:created_by,:string
    remove_column :guides,:relateds
    change_column :guides,:published,:boolean,:default => false,:null => false
    change_column :feeds,:label,:string
    change_column :feeds,:url,:string
    change_column :feeds,:rss_resource_id,:integer
    change_column :dods,:proxy,:integer,:default => 0
    change_column :dods,:url,:string, :default => "",:null => false,:limit => 555
    change_column :dods,:title,:string,:limit => 191,:default => "",:null => false
    change_column :dods,:startdate,:string,:limit => 150,:default => "unknown"
    change_column :dods,:enddate,:string,:limit => 150,:default => "unknown"
    change_column :dods,:provider,:string,:limit => 64,:default => "",:null => false
    #change_column :dods,:descr,:text,:null => false    
    remove_column :database_resources,:published
    remove_column :database_resources,:slug
    change_column :database_resources,:content_type,:string,:default => "Databases" 
    change_column :database_resources,:global,:integer,  :default => 0
    change_column :database_resources,:module_title,:string
    change_column :database_dods,:database_resource_id,:integer
    change_column :database_dods,:dod_id,:integer
    change_column :course_widgets,:module_title,:string
    change_column :course_widgets, :global,:integer,:default => 0
    remove_column :course_widgets, :published
    remove_column :course_widgets, :slug
    remove_column :comment_resources, :published
    remove_column :comment_resources, :slug
    change_column :comment_resources,:module_title,:string
    change_column :comment_resources,:global,:integer,:default => 0
    change_column :comment_resources,:num_displayed,:integer,:default => 3
    remove_column :books, :position
    remove_column :books, :location
    change_column :book_resources,:global,:integer,:default => 0
    change_column :book_resources, :module_title, :string
    remove_column :book_resources, :published
    remove_column :book_resources, :slug
    remove_column :answers, :feedback
    change_column :answers,:correct,:integer,:default => 0
  end
end

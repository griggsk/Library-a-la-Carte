class DemoUpdate < ActiveRecord::Migration
  def self.up
    change_column :answers,:correct,:boolean,:default => false
    remove_index :answers, :name => "quiz_question_id" 
    add_index :answers, :question_id
    remove_index :authorships, :name => "tutorial_id" 
    add_index :authorships, ["tutorial_id", "user_id"] 
    change_column :book_resources, :module_title, :string,:null => false
    change_column :book_resources,:global,:boolean,:default => false
    change_column :book_resources,:slug, :string
    change_column :book_resources,:published, :boolean, :default => false
    change_column :books, :image_id, :string
    remove_index :books, :name => "book_resource_id" 
    add_index :books, :book_resource_id
    change_column :comment_resources,:module_title,:string,:null => false
    change_column :comment_resources,:num_displayed,:integer,:default => 3, :null => true
    change_column :comment_resources,:global,:boolean,:default => false
    change_column :comment_resources, :published, :boolean,:default => false
    change_column :comment_resources, :slug , :string 
    remove_index :comments, :name => "author_email"
    add_index :comments, ["author_email", "created_at"]
    change_column :course_widgets,:module_title,:string,:null => false
    change_column :course_widgets, :global, :boolean,:default => false  
    change_column :course_widgets, :slug , :string
    change_column :course_widgets, :published, :boolean,:default => false
    change_column :database_dods,:database_resource_id,:integer,:null => false
    change_column :database_dods,:dod_id,:integer,:null => false
    remove_index :database_dods, :name => "database_resource_id" 
    add_index :database_dods, ["database_resource_id", "dod_id"]
    change_column :database_resources,:module_title,:string,:null => false
    change_column :database_resources,:global,:boolean,  :default => false
    change_column :database_resources,:content_type,:string, :default => "Databases", :null => true
    change_column :database_resources,:published,:boolean,:default => false
    change_column :database_resources,:slug,:string
    change_column :dods,:title,:string,:null => false
    change_column :dods,:url,:string,:null => false
    change_column :dods,:startdate,:string,:default => "unknown"
    change_column :dods,:enddate,:string,:default => "unknown"
    change_column :dods,:provider,:string,:null => false
    change_column :dods,:proxy,:boolean,:default => false
    remove_index :dods, :name => "title" 
    add_index :dods, :title
    remove_index :feeds, :name => "rss_resource_id" 
    add_index :feeds, :rss_resource_id
    change_column :guides,:created_by,:string, :null => true
    change_column :guides,:published,:boolean,:default => false, :null => true
    remove_index :guides, :name => "resource_id" 
    add_index :guides, :resource_id
    change_column :image_resources,:global,:boolean,:default => false
    change_column :image_resources,:content_type,:string,:default => "Images", :null => true
    change_column :image_resources,:slug,:string
    change_column :image_resources,:size,:string,  :default => "F"
    change_column :image_resources,:orientation,:string,:default => "V"
    change_column :image_resources,:published,:boolean,:default => false
    remove_index :images, :name => "image_resource_id" 
    add_index :images, :image_resource_id
    change_column :inst_resources,:module_title,:string,:null => false
    change_column :inst_resources,:global,:boolean,:default => false
    change_column :inst_resources,:slug,:string 
    change_column :inst_resources,:published,:boolean,:default => false 
    change_column :lib_resources,:module_title,:string,:null => false
    change_column :lib_resources,:global,:boolean,:default => false
    change_column :lib_resources,:slug,:string 
    change_column :lib_resources,:published,:boolean,:default => false 
    change_column :links,:url,:string
    change_column :links,:target,:boolean,:default => false 
    remove_index :links, :name => "url_resource_id" 
    add_index :links, :url_resource_id
    change_column :locals,:banner_url,:string
    change_column :locals,:logo_url,:string
    change_column :locals,:styles,:string
    change_column :locals,:lib_url,:string
    change_column :locals,:univ_url,:string  
    change_column :locals,:js_link,:string 
    change_column :locals,:proxy,:string
    change_column :locals,:enable_search,:boolean,:default => true
    change_column :miscellaneous_resources,:module_title,:string, :null => false
    change_column :miscellaneous_resources,:global,:boolean,:default => false
    change_column :miscellaneous_resources,:slug,:string 
    change_column :miscellaneous_resources,:published,:boolean,:default => false 
    change_column :pages,:published,:boolean,:default => false,:null => true
    change_column :pages,:course_num,:string
    change_column :questions,:q_type,:string,:default => "MC", :null => true
    change_column :questions,:points,:integer,:default => 0, :null =>  true
    change_column :questions,:updated_at,:datetime, :null => true
    remove_column :questions, :image 
    remove_index :questions, :name => "quiz_resource_id" 
    add_index :questions, :quiz_resource_id
    change_column :quiz_resources,:created_by,:string
    change_column :quiz_resources,:content_type,:string,:default => "Quiz", :null => true
    change_column :quiz_resources,:global,:boolean,:default => false
    change_column :quiz_resources,:graded,:boolean,:default => false
    change_column :quiz_resources,:published,:boolean,:default => false 
    change_column :quiz_resources,:slug,:string 
    remove_index :resourceables, :name => "resource_id" 
    add_index :resourceables, ["resource_id", "unit_id"]
    change_column :reserve_resources,:module_title,:string,:null => false
    change_column :reserve_resources,:global,:boolean,:default => false
    change_column :reserve_resources,:slug,:string
    change_column :reserve_resources,:published,:boolean,:default => false
    change_column :results,:score,:integer,:default => 0, :null => true
    remove_index :results, :name => "quiz_resource_id" 
    add_index :results, :question_id
    remove_index :results, :name => "student_id" 
    add_index :results, :student_id
    remove_index :resources_users, :name => "resource_id"
    add_index :resources_users, ["resource_id", "user_id"]
    change_column :rss_resources,:module_title,:string,:null => false
    change_column :rss_resources,:global,:boolean,:default => false
    change_column :rss_resources,:topic,:string, :null => true
    change_column :rss_resources,:num_feeds,:integer,:default => 6, :null => true
    change_column :rss_resources,:style,:string,:default => "mixed", :null => true
    change_column :rss_resources,:slug,:string
    change_column :rss_resources,:published,:boolean,:default => false
    remove_index :sessions, :name => "sessions_session_id_index" 
    add_index :sessions, :session_id
    change_column :students,:firstname,:string, :null => true
    change_column :students,:lastname,:string, :null => true
    change_column :students,:onid,:string, :null => true
    change_column :students,:sect_num,:string
    change_column :students,:email,:string,:null => true
    change_column :subjects,:subject_code,:string,:null => true
    change_column :subjects,:subject_name,:string,:null => true
    change_column :tabs,:tabable_type,:string
    change_column :tabs,:tab_name,:string
    remove_index :tabs, :name => "tabable_id" 
    add_index :tabs, ["tabable_id", "tabable_type"]
    remove_index :taggings, :name => "tag_id" 
    add_index :taggings, ["tag_id"]
    remove_index :taggings, :name => "taggable_id" 
    add_index :taggings, ["taggable_id", "taggable_type"]
    change_column :tutorials,:graded,:boolean,:default => false
    change_column :tutorials,:published,:boolean,:default => false,:null => true
    change_column :tutorials,:archived,:boolean,:default => false,:null => true
    change_column :tutorials,:course_num,:string
    change_column :tutorials,:pass,:string,:default => "p@ssword",:null => true
    remove_index :tutorials, :name => "created_by"
    remove_index :tutorials, :name => "subject_id"
    add_index :tutorials, ["created_by"] 
    add_index :tutorials, ["subject_id"]
    remove_index :unitizations, :name => "unit_id" 
    add_index :unitizations, ["unit_id", "tutorial_id"]
    change_column :units,:slug,:string, :null => true
    remove_index :uploadables, :name => "uploader_uploadable" 
    add_index :uploadables, ["id", "uploader_resource_id"]
    change_column :uploader_resources,:module_title,:string, :default => "", :null => false
    change_column :uploader_resources,:global,:boolean,:default => false
    change_column :uploader_resources,:slug,:string
    change_column :uploader_resources,:published,:boolean,:default => false
    change_column :url_resources,:module_title,:string,:null => false
    change_column :url_resources,:global,:boolean,:default => false
    change_column :url_resources,:slug,:string
    change_column :url_resources,:published,:boolean,:default => false
    change_column :users,:name,:string,:null => false,:default => nil
    change_column :users,:hashed_psswrd,:string,:null => false,:default => nil
    change_column :users,:email,:string,:null => false,:default => nil
    change_column :users,:salt,:string,:null => false,:default => nil
    change_column :video_resources,:module_title,:string,:null => false
    change_column :video_resources,:global,:boolean,:default => false
    change_column :video_resources,:published,:boolean,:default => false
    change_column :video_resources,:slug,:string
    change_column :video_resources,:size,:string,:default => "F"
    change_column :video_resources,:orientation,:string,:default => "V" 
    remove_index :videos, :name => "video_resource_id" 
    add_index :videos, ["video_resource_id"]
  end

  def self.down
    remove_index :videos, :name => "index_videos_on_video_resource_id"
    add_index :videos, ["video_resource_id"], :name => "video_resource_id"
    change_column :video_resources,:module_title,:string,:null => true
    change_column :video_resources, :orientation, :string,  :limit => 5,  :default => "V"
    change_column :video_resources, :size,  :string,  :limit => 5,  :default => "F"
    change_column :video_resources, :published, :integer, :default => 0
    change_column :video_resources, :slug, :string, :limit => 15
    change_column :video_resources, :global, :integer, :default => 0
    change_column :url_resources, :published, :integer, :default => 0
    change_column :url_resources, :slug, :string, :limit => 15
    change_column :url_resources, :global, :integer, :default => 0
    change_column :url_resources, :module_title, :string, :limit => 55, :default => "", :null => true
    change_column :uploader_resources, :published, :integer, :default => 0
    change_column :uploader_resources, :slug, :string, :limit => 15
    change_column :uploader_resources, :global, :integer, :default => 0
    change_column :uploader_resources, :module_title, :string, :limit => 55, :default => "Course Materials", :null => true
    remove_index :uploadables, :name => "index_uploadables_on_id_and_uploader_resource_id"
    add_index :uploadables, ["id", "uploader_resource_id"], :name => "uploader_uploadable"
    change_column :units,:slug,:string, :limit => 55, :null => false
    remove_index :unitizations, :name => "index_unitizations_on_unit_id_and_tutorial_id"
    add_index :unitizations, ["unit_id", "tutorial_id"], :name => "unit_id"
    remove_index :tutorials, :name => "index_tutorials_on_subject_id"
    add_index :tutorials, ["subject_id"], :name => "subject_id"
    remove_index :tutorials, :name => "index_tutorials_on_created_by"
    add_index :tutorials, ["created_by"], :name => "created_by"
    change_column :tutorials, :pass, :string, :limit => 55, :default => "Ken Kesey", :null => false
    change_column :tutorials, :course_num, :string, :limit =>55
    change_column :tutorials, :archived, :boolean, :default => false, :null => false
    change_column :tutorials, :published, :boolean, :default => false,       :null => false
    change_column :tutorials, :graded, :integer, :limit => 1, :default => 0
    remove_index :taggings, :name => "index_taggings_on_taggable_id_and_taggable_type"
    add_index :taggings, ["taggable_id", "taggable_type"], :name => "taggable_id"
    remove_index :taggings, :name => "index_taggings_on_tag_id"
    add_index :taggings, ["tag_id"], :name => "tag_id"
    remove_index :tabs, :name => "index_tabs_on_tabable_id_and_tabable_type"
    add_index :tabs, ["tabable_id", "tabable_type"], :name => "tabable_id"
    change_column :tabs, :tab_name, :string, :limit =>20
    change_column :tabs , :tabable_type, :string, :limit => 55
    change_column :subjects, :subject_name, :string, :null => false
    change_column :subjects, :subject_code, :string, :null => false
    change_column :students, :email, :string, :null => false
    change_column :students, :sect_num, :string, :limit => 55
    change_column :students, :onid, :string, :limit => 55, :null => false
    change_column :students, :lastname, :string, :null => false
    change_column :students, :firstname, :string, :null => false
    remove_index :sessions, :name => "index_sessions_on_session_id"
    add_index :sessions, ["session_id"], :name => "sessions_session_id_index"
    change_column :rss_resources, :published, :integer, :default => 0
    change_column :rss_resources, :slug, :string, :limit => 15
    change_column :rss_resources, :style, :string, :limit => 55,  :default => "mixed",     :null => false
    change_column :rss_resources, :num_feeds, :integer, :default => 6,           :null => false
    change_column :rss_resources, :topic, :string, :limit => 100,                          :null => false
    change_column :rss_resources, :global, :integer, :limit => 1,   :default => 0
    change_column :rss_resources, :module_title, :string, :limit => 55,  :default => "", :null => true
    remove_index :results, :name => "index_results_on_student_id"
    add_index :results, ["student_id"], :name => "student_id"
    remove_index :results, :name =>  "index_results_on_question_id"
    add_index :results, ["question_id"], :name => "quiz_resource_id"
    change_column :results, :score, :integer, :default => 0, :null => false
    remove_index :resources_users, :name => "index_resources_users_on_resource_id_and_user_id"
    add_index :resources_users, ["resource_id", "user_id"], :name => "resource_id"
    remove_index :resourceables, :name => "index_resourceables_on_resource_id_and_unit_id"
    add_index :resourceables, ["resource_id", "unit_id"], :name => "resource_id"
    change_column :reserve_resources, :published, :integer,  :default => 0
    change_column :reserve_resources, :slug, :string, :limit => 15
    change_column :reserve_resources, :global, :integer, :limit => 1,  :default => 0
    change_column :reserve_resources, :module_title, :string, :limit => 55, :default => "", :null => true
    change_column :quiz_resources, :published, :integer, :default => 0
    change_column :quiz_resources, :global, :integer, :limit => 1, :default => 0
    change_column :quiz_resources, :slug, :string, :limit => 15
    change_column :quiz_resources, :graded, :integer, :default => 0
    change_column :quiz_resources, :content_type, :string, :limit => 55, :default => "Quiz", :null => false
    change_column :quiz_resources, :created_by, :string, :limit => 11
    remove_index :questions, :name => "index_questions_on_quiz_resource_id"
    add_index :questions, ["quiz_resource_id"], :name => "quiz_resource_id"
    add_column :questions, :image, :text
    change_column :questions, :updated_at, :datetime, :null => false
    change_column :questions, :q_type, :string, :limit => 55, :default => "MC", :null => false
    change_column :questions, :points, :integer, :default => 0,    :null => false
    change_column :pages, :course_num, :string, :limit => 55
    change_column :pages, :published, :boolean, :default => false, :null => false
    change_column :miscellaneous_resources, :published, :integer, :default => 0
    change_column :miscellaneous_resources, :slug, :string, :limit => 15
    change_column :miscellaneous_resources, :global, :integer, :limit => 1, :default => 0
    change_column :miscellaneous_resources, :module_title, :string, :default => "", :null => true
    change_column :locals, :enable_search, :integer, :limit => 1,   :default => 1
    change_column :locals, :proxy, :string, :limit => 500
    change_column :locals, :js_link, :string, :limit => 555
    change_column :locals, :univ_url, :string, :limit => 555
    change_column :locals, :lib_url, :string, :limit => 555
    change_column :locals, :styles, :string, :limit => 555
    change_column :locals, :logo_url, :string, :limit => 555
    change_column :locals, :banner_url, :string, :limit => 555
    remove_index :links, :name => "index_links_on_url_resource_id"
    add_index :links, ["url_resource_id"], :name => "url_resource_id"
    change_column :links, :target, :integer, :limit => 2, :default => 0
    change_column :links, :url, :string, :limit => 555
    change_column :lib_resources, :published, :integer, :default => 0
    change_column :lib_resources, :slug, :string, :limit => 15
    change_column :lib_resources, :global, :integer, :limit => 1, :default => 0
    change_column :lib_resources, :module_title, :string, :limit => 55, :default => "", :null => true
    change_column :inst_resources, :published, :integer, :default => 0
    change_column :inst_resources, :slug, :string, :limit => 15
    change_column :inst_resources, :global, :integer, :limit => 1, :default => 0
    change_column :inst_resources, :module_title, :string, :limit => 55, :default => "", :null => true
    remove_index :images, :name => "index_images_on_image_resource_id"
    add_index :images, ["image_resource_id"], :name => "image_resource_id"
    change_column :image_resources, :published, :integer, :default => 0
    change_column :image_resources, :orientation, :string, :limit => 5,  :default => "V"
    change_column :image_resources, :size, :string, :limit => 5,  :default => "F"
    change_column :image_resources, :slug, :string, :limit => 15
    change_column :image_resources, :content_type, :string, :default => "Images", :null => false
    change_column :image_resources, :global, :integer, :default => 0
    remove_index :guides, :name => "index_guides_on_resource_id"
    add_index :guides, ["resource_id"], :name => "resource_id"
    change_column :guides, :published, :boolean, :default => false, :null => false
    change_column :guides, :created_by, :string, :null => false
    remove_index :feeds, :name => "index_feeds_on_rss_resource_id"
    add_index :feeds, ["rss_resource_id"], :name => "rss_resource_id"
    remove_index :dods, :name => "index_dods_on_title"
    add_index :dods, ["title"], :name => "title"
    change_column :dods, :proxy, :integer, :limit => 1,   :default => 0
    change_column :dods, :provider, :string, :limit => 64,  :default => "",        :null => false
    change_column :dods, :enddate, :string, :limit => 150, :default => "unknown"
    change_column :dods, :startdate, :string, :limit => 155, :default => "unknown"
    change_column :dods, :url, :string, :limit => 555,                        :null => false
    change_column :dods, :title, :string, :limit => 191, :default => "",        :null => false
    change_column :database_resources, :published, :integer, :default => 0
    change_column :database_resources, :slug, :string, :limit => 15
    change_column :database_resources, :content_type, :string, :limit => 55, :default => "Databases", :null => false
    change_column :database_resources, :global, :integer, :limit => 1,  :default => 0
    change_column :database_resources, :module_title, :string, :limit => 55
    remove_index :database_dods, :name => "index_database_dods_on_database_resource_id_and_dod_id"
    add_index :database_dods, ["database_resource_id", "dod_id"], :name => "database_resource_id"
    change_column :database_dods, :dod_id, :integer, :null => true
    change_column :database_dods, :database_resource_id, :integer, :null => true
    change_column :course_widgets, :published, :integer, :default => 0
    change_column :course_widgets, :slug, :string, :limit => 15
    change_column :course_widgets, :global, :integer, :limit => 1,  :default => 0
    remove_index :comments, :name => "index_comments_on_author_email_and_created_at"
    add_index :comments, ["author_email", "created_at"], :name => "author_email"
    change_column :comment_resources, :published, :integer,:default => 0
    change_column :comment_resources, :slug, :string, :limit => 15
    change_column :comment_resources, :global, :integer,:limit => 1,  :default => 0
    change_column :comment_resources, :num_displayed, :integer, :default => 3,          :null => false
    remove_index :books, :name => "index_books_on_book_resource_id"
    add_index :books, ["book_resource_id"], :name => "book_resource_id"
    change_column :books, :image_id, :string, :limit => 55
    change_column :book_resources, :published, :integer, :default => 0
    change_column :book_resources, :slug, :string, :limit => 15
    change_column :book_resources, :global, :integer, :default => 0
    change_column :book_resources, :module_title, :string, :limit => 55, :default => "", :null => false
    remove_index :authorships, :name => "index_authorships_on_tutorial_id_and_user_id"
    add_index :authorships, ["tutorial_id", "user_id"], :name => "tutorial_id"
    remove_index :answers, :name => "index_answers_on_question_id"
    add_index :answers, ["question_id"], :name => "quiz_question_id"
    change_column :answers, :correct, :integer, :default => 0
  end
end

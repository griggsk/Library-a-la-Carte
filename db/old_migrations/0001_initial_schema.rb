# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 1) do

  create_table "answers", :force => true do |t|
    t.integer "question_id"
    t.text    "value"
    t.boolean "correct",     :default => false
    t.integer "position"
  end

  add_index "answers", ["question_id"], :name => "quiz_question_id"

  create_table "authorships", :force => true do |t|
    t.integer "tutorial_id",                :null => false
    t.integer "user_id",                    :null => false
    t.integer "rights",      :default => 1, :null => false
  end

  add_index "authorships", ["tutorial_id", "user_id"], :name => "tutorial_id"

  create_table "book_resources", :force => true do |t|
    t.string   "module_title"
    t.string   "label"
    t.datetime "updated_at"
    t.string   "content_type",  :default => "Books"
    t.boolean  "global",        :default => false
    t.string   "created_by"
    t.integer  "created_by_id"
    t.text     "information"
  end

  create_table "books", :force => true do |t|
    t.string  "url"
    t.text    "description"
    t.string  "label"
    t.integer "book_resource_id"
    t.string  "image_id"
    t.text    "catalog_results"
  end

  add_index "books", ["book_resource_id"], :name => "book_resource_id"

  create_table "comment_resources", :force => true do |t|
    t.string   "module_title"
    t.string   "label"
    t.text     "topic"
    t.integer  "num_displayed", :default => 3
    t.datetime "updated_at"
    t.string   "content_type",  :default => "Comments"
    t.boolean  "global",        :default => false
    t.string   "created_by"
  end

  create_table "comments", :force => true do |t|
    t.integer  "comment_resource_id",                          :null => false
    t.string   "author_name",         :default => "Anonymous", :null => false
    t.string   "author_email"
    t.text     "body",                                         :null => false
    t.datetime "created_at",                                   :null => false
  end

  add_index "comments", ["author_email", "created_at"], :name => "author_email"

  create_table "course_widgets", :force => true do |t|
    t.string   "module_title"
    t.string   "label"
    t.text     "widget"
    t.text     "information"
    t.datetime "updated_at"
    t.string   "content_type", :default => "Multi-Media Widget"
    t.boolean  "global",        :default => false
    t.string   "created_by"
  end

  create_table "database_dods", :force => true do |t|
    t.integer "database_resource_id"
    t.integer "dod_id"
    t.text    "description"
    t.integer "location"
  end

  add_index "database_dods", ["database_resource_id", "dod_id"], :name => "database_resource_id"

  create_table "database_resources", :force => true do |t|
    t.string   "created_by"
    t.datetime "updated_at"
    t.string   "module_title"
    t.boolean  "global",        :default => false
    t.string   "content_type", :default => "Databases"
    t.string   "label"
    t.text     "info"
  end

  create_table "dods", :force => true do |t|
    t.string  "title",       :limit => 191, :default => "",        :null => false
    t.string  "url",         :limit => 555, :default => "",        :null => false
    t.string  "startdate",   :limit => 155, :default => "unknown"
    t.string  "enddate",     :limit => 150, :default => "unknown"
    t.string  "provider",    :limit => 64,  :default => "",        :null => false
    t.string  "providerurl"
    t.boolean "proxy",                      :default => false
    t.text    "descr",                                             :null => false
  end

  add_index "dods", ["title"], :name => "title"

  create_table "feeds", :force => true do |t|
    t.string  "label"
    t.string  "url"
    t.integer "rss_resource_id"
  end

  add_index "feeds", ["rss_resource_id"], :name => "rss_resource_id"

  create_table "guides", :force => true do |t|
    t.string   "guide_name",                     :null => false
    t.integer  "resource_id"
    t.datetime "updated_at"
    t.string   "created_by"
    t.boolean  "published",   :default => false, :null => false
    t.text     "description"
  end

  add_index "guides", ["resource_id"], :name => "resource_id"

  create_table "guides_masters", :id => false, :force => true do |t|
    t.integer "guide_id"
    t.integer "master_id"
  end

  add_index "guides_masters", ["guide_id"], :name => "index_guides_masters_on_guide_id"
  add_index "guides_masters", ["master_id"], :name => "index_guides_masters_on_master_id"

  create_table "guides_subjects", :id => false, :force => true do |t|
    t.integer "guide_id"
    t.integer "subject_id"
  end

  add_index "guides_subjects", ["guide_id"], :name => "index_guides_subjects_on_guide_id"
  add_index "guides_subjects", ["subject_id"], :name => "index_guides_subjects_on_subject_id"

  create_table "guides_users", :id => false, :force => true do |t|
    t.integer "guide_id"
    t.integer "user_id"
  end

  add_index "guides_users", ["guide_id"], :name => "index_guides_users_on_guide_id"
  add_index "guides_users", ["user_id"], :name => "index_guides_users_on_user_id"

  create_table "image_managers", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
  end

  create_table "image_resources", :force => true do |t|
    t.string   "module_title"
    t.string   "label"
    t.string   "created_by"
    t.datetime "updated_at"
    t.text     "information"
    t.boolean  "global",        :default => false
    t.string   "content_type", :default => "Images"
  end

  create_table "images", :force => true do |t|
    t.integer "image_resource_id"
    t.string  "url"
    t.text    "description"
    t.string  "alt"
  end

  add_index "images", ["image_resource_id"], :name => "image_resource_id"

  create_table "inst_resources", :force => true do |t|
    t.string   "module_title"
    t.string   "label"
    t.string   "instructor_name"
    t.string   "email"
    t.string   "office_location"
    t.string   "office_hours"
    t.string   "website"
    t.datetime "updated_at"
    t.string   "content_type",    :default => "Instructor Profile"
    t.boolean  "global",        :default => false
    t.string   "created_by"
  end

  create_table "lf_targets", :force => true do |t|
    t.integer "libfind_resource_id"
    t.string  "value"
  end

  create_table "lib_resources", :force => true do |t|
    t.string   "module_title"
    t.string   "label"
    t.string   "librarian_name"
    t.string   "email"
    t.string   "chat_info"
    t.string   "office_hours"
    t.string   "office_location"
    t.text     "chat_widget"
    t.datetime "updated_at"
    t.string   "content_type",    :default => "Librarian Profile"
    t.boolean  "global",        :default => false
    t.string   "created_by"
    t.text     "image_info"
  end

  create_table "libfind_resources", :force => true do |t|
    t.string   "module_title"
    t.string   "label"
    t.text     "information"
    t.datetime "updated_at"
    t.string   "content_type", :default => "LibraryFind Search"
    t.boolean  "global",        :default => false
    t.string   "created_by"
  end

  create_table "links", :force => true do |t|
    t.string  "url"
    t.text    "description"
    t.string  "label"
    t.integer "url_resource_id"
  end

  add_index "links", ["url_resource_id"], :name => "url_resource_id"

  create_table "locals", :force => true do |t|
    t.string  "banner_url"
    t.string  "logo_url"
    t.text    "styles"
    t.string  "lib_name"
    t.string  "lib_url"
    t.string  "univ_name"
    t.string  "univ_url"
    t.string  "link_one"
    t.string  "link_two"
    t.string  "link_three"
    t.string  "name_one"
    t.string  "name_two"
    t.string  "name_three"
    t.string  "lib_help"
    t.text    "lib_chat"
    t.text    "footer"
    t.text    "book_search"
    t.text    "site_search"
    t.text    "g_search"
    t.text    "g_results"
    t.text    "image_map"
    t.string  "ica_page_title",      :default => "Get Help with a Class"
    t.string  "guide_page_title",    :default => "Get Help with a Subject"
    t.string  "tutorial_page_title", :default => "Online Research Tutorials"
    t.integer "logo_width"
    t.integer "logo_height"
    t.text    "types"
    t.text    "guides"
    t.string  "proxy"
  end

  create_table "masters", :force => true do |t|
    t.string "value"
  end

  create_table "miscellaneous_resources", :force => true do |t|
    t.string   "module_title"
    t.string   "label"
    t.text     "content"
    t.text     "more_info"
    t.string   "created_by"
    t.datetime "updated_at"
    t.boolean  "global",        :default => false
    t.string   "content_type", :default => "Custom Content"
  end

  create_table "pages", :force => true do |t|
    t.boolean  "published",        :default => false, :null => false
    t.string   "sect_num"
    t.string   "course_name"
    t.string   "term"
    t.string   "year"
    t.string   "course_num"
    t.text     "page_description"
    t.datetime "updated_at"
    t.date     "created_on"
    t.boolean  "archived",         :default => false, :null => false
    t.string   "created_by"
    t.integer  "resource_id"
    t.text     "relateds"
  end

  create_table "pages_subjects", :id => false, :force => true do |t|
    t.integer "page_id"
    t.integer "subject_id"
  end

  add_index "pages_subjects", ["page_id"], :name => "index_pages_subjects_on_page_id"
  add_index "pages_subjects", ["subject_id"], :name => "index_pages_subjects_on_subject_id"

  create_table "pages_users", :id => false, :force => true do |t|
    t.integer "page_id"
    t.integer "user_id"
  end

  add_index "pages_users", ["page_id"], :name => "index_pages_users_on_page_id"
  add_index "pages_users", ["user_id"], :name => "index_pages_users_on_user_id"

  create_table "questions", :force => true do |t|
    t.integer  "quiz_resource_id",                   :null => false
    t.text     "question",                           :null => false
    t.integer  "position"
    t.integer  "points",           :default => 0,    :null => false
    t.string   "q_type",           :default => "MC", :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "questions", ["quiz_resource_id"], :name => "quiz_resource_id"

  create_table "quiz_resources", :force => true do |t|
    t.string   "module_title"
    t.string   "label"
    t.text     "description"
    t.string   "created_by"
    t.datetime "updated_at"
    t.string   "content_type", :default => "Quiz"
    t.boolean  "graded",        :default => false
    t.integer  "global",           :default => 0
  end

  create_table "reserve_resources", :force => true do |t|
    t.string   "module_title"
    t.string   "label"
    t.text     "reserves"
    t.text     "library_reserves"
    t.string   "course_title"
    t.datetime "updated_at"
    t.string   "content_type",     :default => "Course Reserves"
    t.boolean  "global",        :default => false
    t.string   "created_by"
  end

  create_table "resourceables", :force => true do |t|
    t.integer "resource_id", :null => false
    t.integer "unit_id",     :null => false
    t.integer "position",    :null => false
  end

  add_index "resourceables", ["resource_id", "unit_id"], :name => "resource_id"

  create_table "resources", :force => true do |t|
    t.integer "mod_id"
    t.string  "mod_type"
  end

  create_table "resources_users", :id => false, :force => true do |t|
    t.integer "resource_id"
    t.integer "user_id"
  end

  add_index "resources_users", ["resource_id", "user_id"], :name => "resource_id"

  create_table "results", :force => true do |t|
    t.integer  "student_id"
    t.integer  "score",       :default => 0
    t.datetime "updated_at"
    t.integer  "question_id"
    t.text     "guess"
  end

  add_index "results", ["question_id"], :name => "quiz_resource_id"
  add_index "results", ["student_id"], :name => "student_id"

  create_table "rss_resources", :force => true do |t|
    t.string   "module_title"
    t.string   "label"
    t.datetime "updated_at"
    t.string   "content_type", :default => "RSS Feeds"
    t.boolean  "global",        :default => false
    t.string   "created_by"
    t.text     "information"
    t.string   "topic"
    t.integer  "num_feeds",    :default => 6
    t.string   "style",        :default => "mixed"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "sessions_session_id_index"

  create_table "students", :force => true do |t|
    t.string   "name",        :default => "", :null => false
    t.datetime "created_on"
    t.string   "onid",        :default => "", :null => false
    t.string   "sect_num"
    t.string   "email",       :default => "", :null => false
    t.integer  "tutorial_id"
  end

  create_table "subjects", :force => true do |t|
    t.string "subject_code", :default => "", :null => false
    t.string "subject_name", :default => "", :null => false
  end

  create_table "tab_resources", :force => true do |t|
    t.integer "tab_id"
    t.integer "resource_id"
    t.integer "position"
  end

  add_index "tab_resources", ["resource_id"], :name => "index_tab_resources_on_resource_id"
  add_index "tab_resources", ["tab_id"], :name => "index_tab_resources_on_tab_id"

  create_table "tabs", :force => true do |t|
    t.string   "tab_name",   :limit => 20
    t.integer  "guide_id"
    t.datetime "updated_at"
    t.integer  "position"
    t.integer  "template",                 :default => 2
    t.integer  "page_id"
  end

  add_index "tabs", ["guide_id"], :name => "guide_id"
  add_index "tabs", ["page_id"], :name => "page_id"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "taggable_id"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "tutorials", :force => true do |t|
    t.integer  "subject_id"
    t.string   "name",        :default => "",          :null => false
    t.text     "description"
    t.boolean  "graded",      :default => false
    t.boolean  "published",   :default => false,           :null => false
    t.boolean  "archived",    :default => false,           :null => false
    t.integer  "created_by"
    t.datetime "updated_at"
    t.string   "course_num"
    t.text     "section_num"
    t.string   "pass",        :default => "Ken Kesey", :null => false
  end

  add_index "tutorials", ["created_by"], :name => "created_by"
  add_index "tutorials", ["subject_id"], :name => "subject_id"

  create_table "unitizations", :force => true do |t|
    t.integer "unit_id",     :null => false
    t.integer "tutorial_id", :null => false
    t.integer "position"
  end

  add_index "unitizations", ["unit_id", "tutorial_id"], :name => "unit_id"

  create_table "units", :force => true do |t|
    t.string   "title",       :default => "", :null => false
    t.text     "description"
    t.integer  "created_by"
    t.datetime "updated_at"
  end

  create_table "uploadables", :force => true do |t|
    t.string   "upload_file_name"
    t.string   "upload_content_type"
    t.integer  "upload_file_size"
    t.datetime "upload_updated_at"
    t.integer  "uploader_resource_id"
    t.text     "upload_info"
    t.string   "upload_link"
  end

  add_index "uploadables", ["id", "uploader_resource_id"], :name => "uploader_uploadable"

  create_table "uploader_resources", :force => true do |t|
    t.string   "module_title"
    t.string   "label"
    t.boolean  "global",       :default => false
    t.string   "created_by"
    t.datetime "updated_at"
    t.string   "content_type", :default => "Attachments"
    t.text     "info"
  end

  create_table "url_resources", :force => true do |t|
    t.string   "module_title"
    t.string   "label"
    t.datetime "updated_at"
    t.string   "content_type",  :default => "Web Links"
    t.boolean  "global",        :default => false
    t.string   "created_by"
    t.integer  "created_by_id"
    t.text     "information"
  end

  create_table "users", :force => true do |t|
    t.string  "name",          :default => "",       :null => false
    t.string  "hashed_psswrd", :default => "",       :null => false
    t.string  "email",         :default => "",       :null => false
    t.string  "salt",          :default => "",       :null => false
    t.string  "role",          :default => "author", :null => false
    t.integer "resource_id"
  end

  create_table "video_resources", :force => true do |t|
    t.string   "module_title"
    t.string   "label"
    t.string   "created_by"
    t.datetime "updated_at"
    t.boolean  "global",        :default => false
    t.string   "content_type", :default => "Videos"
    t.text     "information"
  end

  create_table "videos", :force => true do |t|
    t.integer "video_resource_id"
    t.string  "url"
    t.text    "description"
    t.string  "alt"
  end

  add_index "videos", ["video_resource_id"], :name => "video_resource_id"

end

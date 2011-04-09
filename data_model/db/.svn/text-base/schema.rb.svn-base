# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 11) do

  create_table "cattribute_edges", :force => true do |t|
    t.string  "ky"
    t.string  "val"
    t.integer "in_site_id"
    t.integer "out_site_id"
  end

  add_index "cattribute_edges", ["ky"], :name => "index_cattribute_edges_on_ky"
  add_index "cattribute_edges", ["val"], :name => "index_cattribute_edges_on_val"
  add_index "cattribute_edges", ["in_site_id"], :name => "index_cattribute_edges_on_in_site_id"
  add_index "cattribute_edges", ["out_site_id"], :name => "index_cattribute_edges_on_out_site_id"

  create_table "cattribute_sedges", :force => true do |t|
    t.integer "out_site_mcount"
    t.integer "in_site_mcount"
    t.integer "common"
    t.integer "in_site_id"
    t.integer "out_site_id"
  end

  add_index "cattribute_sedges", ["out_site_id"], :name => "index_cattribute_sedges_on_out_site_id"
  add_index "cattribute_sedges", ["in_site_id"], :name => "index_cattribute_sedges_on_in_site_id"

  create_table "cattributes", :force => true do |t|
    t.string  "type"
    t.string  "key"
    t.string  "val"
    t.integer "cmodule_id"
    t.integer "site_id"
  end

  add_index "cattributes", ["cmodule_id"], :name => "index_cattributes_on_cmodule_id"
  add_index "cattributes", ["site_id"], :name => "index_cattributes_on_site_id"
  add_index "cattributes", ["key"], :name => "index_cattributes_on_key"
  add_index "cattributes", ["val"], :name => "index_cattributes_on_val"

  create_table "cmodules", :force => true do |t|
    t.string  "name"
    t.integer "site_id"
  end

  add_index "cmodules", ["name"], :name => "index_cmodules_on_name"
  add_index "cmodules", ["site_id"], :name => "index_cmodules_on_site_id"

  create_table "jaccard2", :id => false, :force => true do |t|
    t.integer "in_site_id"
    t.integer "out_site_id"
    t.integer "common"
    t.decimal "jaccard",         :precision => 18, :scale => 8
    t.decimal "jaccard_common",  :precision => 14, :scale => 4
    t.integer "in_site_mcount"
    t.integer "out_site_mcount"
  end

  add_index "jaccard2", ["in_site_id"], :name => "in_site_id"
  add_index "jaccard2", ["out_site_id"], :name => "out_site_id"

  create_table "jaccard_medges", :id => false, :force => true do |t|
    t.integer "in_site_id"
    t.integer "out_site_id"
    t.integer "common"
    t.decimal "jaccard",         :precision => 18, :scale => 8
    t.decimal "jaccard_common",  :precision => 14, :scale => 4
    t.integer "in_site_mcount"
    t.integer "out_site_mcount"
  end

  create_table "medges", :force => true do |t|
    t.integer "in_site_id"
    t.integer "out_site_id"
    t.string  "description"
  end

  add_index "medges", ["in_site_id"], :name => "index_medges_on_in_site_id"
  add_index "medges", ["out_site_id"], :name => "index_medges_on_out_site_id"
  add_index "medges", ["description"], :name => "index_medges_on_description"

  create_table "sedges", :force => true do |t|
    t.integer "in_site_id"
    t.integer "out_site_id"
    t.integer "common"
    t.float   "jaccard"
  end

  create_table "sites", :force => true do |t|
    t.string  "url"
    t.string  "query"
    t.string  "path"
    t.integer "m_count"
  end

  create_table "smedges", :force => true do |t|
    t.integer "in_site_id"
    t.integer "out_site_id"
    t.integer "common"
  end

end

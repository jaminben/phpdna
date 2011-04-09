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

ActiveRecord::Schema.define(:version => 20081004201034) do

  create_table "compare_caches", :force => true do |t|
    t.integer "phpinfo_id", :limit => 11
    t.text    "data"
  end

  add_index "compare_caches", ["phpinfo_id"], :name => "index_compare_caches_on_phpinfo_id"

  create_table "compare_edges", :force => true do |t|
    t.integer "in_id",        :limit => 11
    t.integer "out_id",       :limit => 11
    t.float   "mods_jaccard"
    t.float   "attr_jaccard"
    t.text    "cache"
  end

  add_index "compare_edges", ["in_id"], :name => "index_compare_edges_on_in_id"
  add_index "compare_edges", ["out_id"], :name => "index_compare_edges_on_out_id"
  add_index "compare_edges", ["mods_jaccard"], :name => "index_compare_edges_on_mods_jaccard"
  add_index "compare_edges", ["attr_jaccard"], :name => "index_compare_edges_on_attr_jaccard"

  create_table "modnames", :force => true do |t|
    t.string "modname"
  end

  add_index "modnames", ["modname"], :name => "index_modnames_on_modname"

  create_table "pattributes", :force => true do |t|
    t.integer "pmodule_id",       :limit => 11
    t.integer "pkey_id",          :limit => 11
    t.integer "pvalue_id",        :limit => 11
    t.integer "pvalue_master_id", :limit => 11
  end

  add_index "pattributes", ["pkey_id"], :name => "index_pattributes_on_pkey_id"
  add_index "pattributes", ["pvalue_id"], :name => "index_pattributes_on_pvalue_id"
  add_index "pattributes", ["pmodule_id"], :name => "index_pattributes_on_pmodule_id"
  add_index "pattributes", ["pvalue_master_id"], :name => "index_pattributes_on_pvalue_master_id"

  create_table "pconfig_flat", :force => true do |t|
    t.integer "pconfig_id",       :limit => 11, :default => 0, :null => false
    t.string  "type"
    t.integer "site_id",          :limit => 11
    t.integer "modname_id",       :limit => 11
    t.integer "pkey_id",          :limit => 11
    t.integer "pvalue_id",        :limit => 11
    t.integer "pvalue_master_id", :limit => 11
  end

  create_table "pconfigs", :force => true do |t|
    t.integer  "site_id",      :limit => 11
    t.text     "raw"
    t.string   "local_copy"
    t.string   "md5_hash"
    t.string   "fingerprint"
    t.datetime "last_checked"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.boolean  "current",                    :default => true
  end

  add_index "pconfigs", ["site_id"], :name => "index_phpinfos_on_site_id"
  add_index "pconfigs", ["type"], :name => "index_pconfigs_on_type"
  add_index "pconfigs", ["current"], :name => "index_pconfigs_on_current"

  create_table "pkeys", :force => true do |t|
    t.string "pkey"
  end

  add_index "pkeys", ["pkey"], :name => "index_pkeys_on_pkey"

  create_table "pmodules", :force => true do |t|
    t.integer "pconfig_id", :limit => 11
    t.integer "modname_id", :limit => 11
  end

  add_index "pmodules", ["pconfig_id"], :name => "index_pmodules_on_phpinfo_id"
  add_index "pmodules", ["modname_id"], :name => "index_pmodules_on_modname_id"

  create_table "pvalues", :force => true do |t|
    t.text "pvalue"
  end

  create_table "sites", :force => true do |t|
    t.string   "url"
    t.string   "ip_address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "host"
  end

end

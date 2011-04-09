class CreatePhpinfos < ActiveRecord::Migration
  def self.up
    create_table :phpinfos do |t|
      t.references  :site
      t.text        :raw              # store a copy in the DB?
      t.string      :local_copy       # if we have it on disk?
      t.string      :md5_hash
      t.string      :fingerprint      # another md5 like method
                                      # more focused on variables
                                      # that don't change on page-reload
                                      
      t.datetime    :last_checked     # for the case where we check it
                                      # and there was no change ... maybe 
      t.timestamps
      
    end
    add_index :phpinfos, :site_id
  end

  def self.down
    drop_table :phpinfos
  end
end

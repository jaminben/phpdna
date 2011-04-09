class CreateCompareCaches < ActiveRecord::Migration
  def self.up
    #
    # This is just storage of JSON information
    #
    
    create_table :compare_caches do |t|
      t.references :phpinfo
      t.text       :data
      #t.timestamps
    end
    add_index :compare_caches, :phpinfo_id
    
  end

  def self.down
    drop_table :compare_caches
  end
end



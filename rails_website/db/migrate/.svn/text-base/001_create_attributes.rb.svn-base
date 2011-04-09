class CreateAttributes < ActiveRecord::Migration
  def self.up
    create_table :cattributes do |t|
      t.column :type, :string
      t.column :key, :string
      t.column :val, :string
      t.column :cmodule_id, :integer
      t.column :site_id, :integer
      
      

    end
    add_index :cattributes, :cmodule_id
    add_index :cattributes, :site_id
    add_index :cattributes, :key
    add_index :cattributes, :val
  end

  def self.down
    drop_table :attributes
  end
end

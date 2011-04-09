class CreatePattributes < ActiveRecord::Migration
  def self.up
    create_table :pattributes do |t|
      t.references :pmodule
      t.references :pkey
      t.references :pvalue
      
      t.integer :pvalue_master_id   # for variable that have global and local
      
#      t.timestamps
    end
    
    add_index :pattributes, :pkey_id
    add_index :pattributes, :pvalue_id
    add_index :pattributes, :pmodule_id
    add_index :pattributes, :pvalue_master_id    
    
  end

  def self.down
    drop_table :pattributes
  end
end

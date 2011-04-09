class CreatePkeys < ActiveRecord::Migration
  def self.up
    create_table :pkeys do |t|
      t.string :pkey
      
#      t.timestamps
      
    end
    
    add_index :pkeys, :pkey
    
  end

  def self.down
    drop_table :pkeys
  end
end

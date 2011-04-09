class CreateModnames < ActiveRecord::Migration
  def self.up
    create_table :modnames do |t|
      t.string :modname
      #t.timestamps
      
    end
    
    add_index :modnames, :modname

  end

  def self.down
    drop_table :modnames
  end
end

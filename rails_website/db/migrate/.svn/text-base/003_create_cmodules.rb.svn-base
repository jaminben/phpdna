class CreateCmodules < ActiveRecord::Migration
  def self.up
    create_table :cmodules do |t|
      t.column :name, :string
      t.column :site_id, :integer


    end
    add_index :cmodules, :name
    add_index :cmodules, :site_id
  end

  def self.down
    drop_table :cmodules
  end
end

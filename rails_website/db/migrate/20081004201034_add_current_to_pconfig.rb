class AddCurrentToPconfig < ActiveRecord::Migration
  def self.up
    add_column :pconfigs, :current, :boolean, :default=>true
    add_index :pconfigs, :current
  end

  def self.down
    remove_column :pconfigs, :current
  end
end

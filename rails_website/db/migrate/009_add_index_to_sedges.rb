class AddIndexToSedges < ActiveRecord::Migration
  def self.up
    add_index :medges, :in_site_id
    add_index :medges, :out_site_id
    add_index :medges, :description
  end

  def self.down
  end
end

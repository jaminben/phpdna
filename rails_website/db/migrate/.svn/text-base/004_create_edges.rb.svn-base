class CreateEdges < ActiveRecord::Migration
  def self.up
    create_table :medges do |t|
      t.column :in_site_id,  :integer
      t.column :out_site_id, :integer
      t.column :description, :string
    end
  end

  def self.down
    drop_table :edges
  end
end

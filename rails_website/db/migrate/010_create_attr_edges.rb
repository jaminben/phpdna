class CreateAttrEdges < ActiveRecord::Migration
  def self.up
    create_table :cattribute_edges do |t|
      t.column :ky, :string
      t.column :val, :string
      t.column :in_site_id, :integer
      t.column :out_site_id, :integer
      
    end
    create_table :cattribute_sedges do |t|
      t.column :out_site_mcount , :integer
      t.column :in_site_mcount  , :integer

      t.column :common, :integer
      t.column :in_site_id, :integer
      t.column :out_site_id, :integer

    end
    
    add_index :cattribute_edges, :ky
    add_index :cattribute_edges, :val
    add_index :cattribute_edges, :in_site_id
    add_index :cattribute_edges, :out_site_id
 
    add_index :cattribute_sedges, :out_site_id
    add_index :cattribute_sedges, :in_site_id    
    
  end

  def self.down
    drop_table :cattribute_sedges
    drop_table :cattribute_edges
    
  end
end

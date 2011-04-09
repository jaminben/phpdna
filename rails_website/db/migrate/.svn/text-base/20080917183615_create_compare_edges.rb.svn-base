class CreateCompareEdges < ActiveRecord::Migration
  def self.up
    create_table :compare_edges do |t|
      t.integer :in_id
      t.integer :out_id
      t.float   :mods_jaccard
      t.float   :attr_jaccard
      
      t.text    :cache   #all the comparison data
      #t.timestamps
    end

    add_index :compare_edges, :in_id
    add_index :compare_edges, :out_id
    add_index :compare_edges, :mods_jaccard
    add_index :compare_edges, :attr_jaccard
        
  end

  def self.down
    drop_table :compare_edges
  end
end

%{
  
  :mods_incommon    => mods_incommon, 
  :mods_diff        => mods_diff,
  :mods_diff_a      => mods_diff & php1.modules_as_set,
  :mods_diff_b      => mods_diff & php2.modules_as_set,

  :mods_jaccard     => mods_jaccard ,
  :attrs_incommon   => attrs_incommon,
  :attrs_diff       => attrs_diff,
  :attrs_diff_a     => attrs_diff & a1,
  :attrs_diff_b     => attrs_diff & a2,
  :attrs_jaccard    => attrs_jaccard,
  
  :keys_diff     => keys_diff,
  :keys_incommon => keys_incommon,
  
  :mods_lada  => mods_lada,
  :keys_lada  => keys_lada,
  :attrs_lada => attrs_lada,
}
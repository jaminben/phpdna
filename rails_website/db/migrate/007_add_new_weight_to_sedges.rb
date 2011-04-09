class AddNewWeightToSedges < ActiveRecord::Migration
  def self.up
    add_column :sedges, :jaccard, :float
  end

  def self.down
    remove_column :sedges, :jaccard
  end
end

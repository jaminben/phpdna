class AddModuleCountToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :m_count, :integer
  end

  def self.down
    remove_column :sites, :m_count
  end
end

class CreateSites < ActiveRecord::Migration
  def self.up
    create_table :sites do |t|
      t.column :url, :string
      t.column :query, :string
      t.column :path, :string
    end
  end

  def self.down
    drop_table :sites
  end
end

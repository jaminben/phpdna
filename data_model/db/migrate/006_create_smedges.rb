class CreateSmedges < ActiveRecord::Migration
  def self.up
    create_table :smedges do |t|
      t.column :in_site_id, :integer
      t.column :out_site_id, :integer
      t.column :common, :integer

    end
  end

  def self.down
    drop_table :smedges
  end
end

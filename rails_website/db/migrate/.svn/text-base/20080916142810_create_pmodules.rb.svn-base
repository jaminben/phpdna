class CreatePmodules < ActiveRecord::Migration
  def self.up
    create_table :pmodules do |t|
      t.references :phpinfo
      t.references :modname
#     t.timestamps

    end
    add_index :pmodules, :phpinfo_id
    add_index :pmodules, :modname_id
  end

  def self.down
    drop_table :pmodules
  end
end

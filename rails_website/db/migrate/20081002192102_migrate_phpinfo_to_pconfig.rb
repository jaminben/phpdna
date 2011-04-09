class MigratePhpinfoToPconfig < ActiveRecord::Migration
  def self.up
    rename_table :phpinfos, :pconfigs
    add_column :pconfigs, :type, :string
    add_index :pconfigs, :type
    
    rename_column :pmodules, :phpinfo_id, :pconfig_id
  end

  def self.down
    rename_column :pmodules, :pconfig_id, :phpinfo_id

    remove_column :pconfigs, :type
    rename_table :pconfigs, :phpinfos
  end
end

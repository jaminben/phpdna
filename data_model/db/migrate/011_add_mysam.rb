class AddMysam < ActiveRecord::Migration
  def self.up
    execute("ALTER TABLE cattribute_sedges ENGINE=MyISAM")
    execute("ALTER TABLE cattribute_edges ENGINE=MyISAM")
  end

  def self.down
  end
end

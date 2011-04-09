require 'uri'
class AddHost < ActiveRecord::Migration
  def self.up
    add_column :sites, :host, :string
    
    Site.find(:all).each do |x|
      x.host = URI.parse(x.url).host
      x.save
    end
    
  end

  def self.down
    remove_column :sites, :host
  end
end

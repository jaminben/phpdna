class Cmodule < ActiveRecord::Base
  belongs_to :site
  has_many :cattributes
  
  def add_attribute(key, value, type = nil)
    a = Cattribute.new
    a.site_id = self.site_id
    a.cmodule_id = self.id
    a.type = type
    a.key  = key
    a.val  = value
    a.save
  end
  
  
end

class Pmodule < ActiveRecord::Base
  has_many :pattributes, :include => [:pkey, :pvalue, :pvalue_master]
  belongs_to :site
  belongs_to :modname
  belongs_to :pconfig
  
  attr_accessor :count
  
  @@mod_frequency = nil


  def name
    return self.modname.modname
  end

  def self.create_by_name_and_pconfig_id(name, pconfig_id)
    mod = Modname.find_or_create_by_modname(name)
    if(!mod.id)
      mod.save
      mod.reload
    end
    
    o = Pmodule.find(:first, :conditions => {:pconfig_id => pconfig_id, :modname_id => mod.id })

    if(!o)
      o = Pmodule.new
      o.pconfig_id = pconfig_id
      o.modname = mod
    end
    
    return o
  end
    

  def self.create_by_name(name)
    o = Pmodule.new
    o.modname = Modname.find_or_create_by_modname(name)
    return o
  end
  
  def add_attribute(key, val )
      a = Pattribute.create_from_key_val(key,val)
      a.pmodule_id = self.id
      a.save
  end

  def attributes_as_set
    # returns the attributes as a simple set of key value pairs
    return @attr_set if (@attr_set)
    @attr_set = Set.new
    
    self.pattributes.each do |pa|
      @attr_set << pa.for_set(self.modname_id)
    end
    return @attr_set
  end

  def keys_as_set
    # returns the attributes as a simple set of key value pairs
    return @attr_keyset if (@attr_keyset)
    @attr_keyset = Set.new
    
    self.pattributes.each do |pa|
      @attr_keyset << (self.modname_id.to_s + "|" + (pa.pkey_id or "").to_s )
    end
    return  @attr_keyset
  end


  def get_freq
    # get the frequency of this module
   return FreqMan.get_mod(self.modname_id)
  end
  
  #
  #
  # I want some co_occurance stuff:
  #
  #
  def cooccuring_modules()
    # 
    # returns modules that Co-Occur.
    return PconfigFlat.co_occuring_modules(self)
  end
  
  
  def cooccuring_module_names( cutoff = 1, limit = 20)
    return PconfigFlat.cooccuring_module_names(self, cutoff, limit)
  end
  
  
  
  
end


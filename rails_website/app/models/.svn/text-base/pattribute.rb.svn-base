#
# TODO --- Redo all the frequencies.
#
#
#

class Pattribute < ActiveRecord::Base
    belongs_to :pmodule
    belongs_to :pvalue
    belongs_to :pkey
    belongs_to :pvalue_master, :class_name=> 'Pvalue', :foreign_key => :pvalue_master_id  

    @@attr_frequency = nil
    @@key_frequency = nil
    @@attr_by_key_frequency = nil
    @@key_mod_frequency = nil
    @@key_mod_overall_frequency = nil
    
    
    def self.create_from_key_val(key,val)
      o = Pattribute.new
      key = key[0..254]   # gotta remember to substring it.
      o.pkey = Pkey.find_or_create_by_pkey(key)
      o.pvalue = Pvalue.find_or_create_by_pvalue(val.shift)
      
      if(val.size > 0)
        o.pvalue_master = Pvalue.find_or_create_by_pvalue(val.join("|") )
      end
      
      return o
    
    end
    
    def value
      return self.pvalue.pvalue
    end
    
    def key
      return self.pkey.pkey
    end

    def key_freq(mod_id)
      return FreqMan.get_key(mod_id, self.pkey_id)
    end
    
    def val_freq(mod_id)
      return FreqMan.get_key_val(mod_id, self.pkey_id, self.pvalue_id)      
    end
    
    def val_master_freq(mod_id)
      return FreqMan.get_key_val(mod_id, self.pkey_id, self.pvalue_id, self.pvalue_master_id)      
    end
    
    def for_set(mod_id)
      return ([mod_id, (self.pkey_id or ""), (self.pvalue_id or ""), (self.pvalue_master_id or "") ].join("|"))
    end
      
    def master_value
      if(self.pvalue_master_id)
        return self.pvalue_master.pvalue
      else
        return nil
      end
    end
  

    # get co-occuring keys
    
    def cooccuring_keys(cutoff = 1, limit = 20)
      return PconfigFlat.cooccuring_keys(self, cutoff, limit)
    end

    def cooccuring_mod_keys(cutoff = 1, limit = 20)
      return PconfigFlat.cooccuring_mod_keys(self, cutoff, limit)
    end

    # for values:
    
    def cooccuring_key_val(cutoff = 1, limit = 20)
      return PconfigFlat.cooccuring_key_val(self, cutoff, limit)
    end
    
    def cooccuring_key_val_mod(cutoff = 1, limit = 20)
      return PconfigFlat.cooccuring_key_val_mod(self, cutoff, limit)
    end
end

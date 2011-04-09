#
# So FreqMan is our clean interface to frequency information for anyone :-)
#
#

class FreqMan
  #
  # I noticed that a lot of people are trying to play with distributions and frequencies.
  # It is relatively stupid to not have a clean interface for everyone to use.
  
  @@current = Set.new
  @@db      = nil
  @stats    = false
  
  def self.db
    return @@db
  end
  
  def self.get_key_frequency(type = nil )
    if(! @@current.include? "key")
      # do a lookup if we don't have it
      @@db = PconfigFlat.get_key_frequency(type)  
      @@current << "key"
      @@current << "mod"
      @@stats = false      
    end
  end
  
  def self.get_mod_frequency(type = nil)
    if(! @@current.include? "mod")
      # do a lookup if we don't have it
      @@db = PconfigFlat.get_mod_frequency(type)  
      @@current << "mod"
      @@stats = false      
    end
  end

  def self.get_key_val_frequency(type = nil)
    if(! @@current.include? "val")
      # do a lookup if we don't have it
      @@db = PconfigFlat.get_key_val_frequency(type)  
      @@current << "mod"
      @@current << "key"
      @@current << "val"
      @@stats = false
    end
  end

  def self.get_key_val_distribution(type = nil)
    FreqMan.get_key_val_frequency(type)
    if(!@@stats)
      PconfigFlat.calcute_distribution(@@db)
      @@stats = true
    end
    
    #return @@db
  end

  def self.get_key_distribution(type = nil)
    FreqMan.get_key_frequency(type)
    if(!@@stats)
      PconfigFlat.calcute_distribution(@@db)
      @@stats = true
    end

    #return @@db
  end

  def self.get_mod_distribution(type = nil)
    FreqMan.get_mod_frequency(type)
    if(!@@stats)
      PconfigFlat.calcute_distribution(@@db)
      @@stats = true
    end

    #return @@db
  end
  
  def self.get_freq_from_str(str, type = nil)
    # given a string
    # return the right key for it
    if(str.class == Fixnum)
      return FreqMan.get_mod(str)[:mcount]
    end
    
    parts = str.split("|")
    
    parts.map! do |j|
      j = nil if(j == "")
      j &&= j.to_i
      j
    end
    
    #p parts
    
    if(parts.size == 1)
      return FreqMan.get_mod(parts[0])[:mcount]
    elsif(parts.size == 2)
      return FreqMan.get_key(parts[0], parts[1])[:sum]
    elsif(parts.size == 3 || (parts.size ==4 && parts[3] == nil))
      return FreqMan.get_key_val(parts[0], parts[1], parts[2])[:sum]
    elsif(parts.size == 4)
      return FreqMan.get_key_val_master(parts[0], parts[1], parts[2], parts[3])[:sum]
    else
      return nil
    end
    
  end
  
  
  def self.get_mod(mod_id, type = nil, dist = true)
    if(dist)
      FreqMan.get_mod_distribution(type)
    else
      FreqMan.get_mod_frequency(type)
    end
    
    #p @@db
    #p mod_id
    #p (@@db[mod_id] == nil)
    
    return { :percent_overall => @@db[mod_id][:percent_overall],
             :sum             => @@db[mod_id][:sum],
             :max             => @@db[mod_id][:max],
             :count           => @@db[mod_id][:count],
             :freq_overall    => @@db[mod_id][:freq_overall], 
             :mcount          => @@db[mod_id][:mcount],
             :percent_mcount  => @@db[mod_id][:percent_mcount]
           }
  end

  def self.get_key(mod_id, key_id, type = nil, dist = true)
    if(dist)
      FreqMan.get_key_val_distribution(type)
      #FreqMan.get_key_distribution(type)
    else
      FreqMan.get_key_val_frequency(type)
      #FreqMan.get_key_frequency(type)
    end
    
    #p "VALS:"
    #p mod_id
    #p key_id
    #p @@db[mod_id][key_id]
    #p @@db[mod_id]
    #p @@db[key_id]
    
    return { :percent_overall => @@db[mod_id][key_id][:percent_overall],
             :percent_mod     => @@db[mod_id][key_id][:percent_mod],
             :sum             => @@db[mod_id][key_id][:sum],
             :max             => @@db[mod_id][key_id][:max],
             :count           => @@db[mod_id][key_id][:count],
             :freq_mod        => @@db[mod_id][key_id][:freq_mod]
           }
  end

  def self.get_key_val(mod_id, key_id, val_id, type = nil, dist = true)
    if(dist)
      FreqMan.get_key_val_distribution(type)
    else
      FreqMan.get_key_val_frequency(type)
    end
    
    return { :percent_overall =>  @@db[mod_id][key_id][val_id][:percent_overall],
             :percent_mod     =>  @@db[mod_id][key_id][val_id][:percent_mod ],
             :sum             =>  @@db[mod_id][key_id][val_id][:sum],
             :max             =>  @@db[mod_id][key_id][val_id][:max],
             :count           =>  @@db[mod_id][key_id][val_id][:count],
             :percent_key     =>  @@db[mod_id][key_id][val_id][:percent_key],
             :freq_value      =>  @@db[mod_id][key_id][val_id][:freq_key]             
           }
  end

  def self.get_key_val_master(mod_id, key_id, val_id, val2_id, type = nil, dist = true)
    if(dist)
      FreqMan.get_key_val_distribution(type)
    else
      FreqMan.get_key_val_frequency(type)
    end
    
    return { :percent_overall =>  @@db[mod_id][key_id][val_id][val2_id][:percent_overall],
             :percent_mod     =>  @@db[mod_id][key_id][val_id][val2_id][:percent_mod],
             :sum             =>  @@db[mod_id][key_id][val_id][val2_id][:sum],
             :max             =>  @@db[mod_id][key_id][val_id][val2_id][:max],
             :count           =>  @@db[mod_id][key_id][val_id][val2_id][:count],             
             :freq_value      =>  @@db[mod_id][key_id][val_id][val2_id][:freq_value],
             :percent_key     =>  @@db[mod_id][key_id][val_id][val2_id][:percent_key]
           }
  end
  
end
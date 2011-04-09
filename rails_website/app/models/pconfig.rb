require 'phpinfo_parser'
require 'digest/md5'

include Math  # load the math module

#
# Add a cool way to grab stuff... stuff meaning .. uhh.. the comparison between this object, and an object of my choice?
#
#

#
# convert all sets, into set operations on INTs to reduce the memory requirements!
#

class Pconfig < ActiveRecord::Base
  belongs_to :site
  has_many   :pmodules, :include => [:modname]
  
  @smart_hash = nil
  
  def set_current
    # Set this Pconfig Current for Site,
    # and all the other's non current.
    
    if(self.type == nil)
      ptype = "and type is null"  
    else
      ptype = "and type = '%s'" % (self.type)
    end
    
    Pconfig.connection.execute("update pconfig set current = 0 where site_id=#{self.site_id.to_i} #{ptype}")
    
    self.current = 1
    self.save
    
  end
  
  def clear
    self.pmodules.each {|x| x.pattributes.clear() }
    self.pmodules.clear()   # clean me up
  end
  
  
  def modules_as_set
    # returns the set of module names
    return @mods_set if(@mods_set)
    @mods_set = Set.new
    
    self.pmodules.each do |pm|
      @mods_set << pm.modname_id
    end
    
    return @mods_set
  end
  
  
  def all_attributes_as_set
    # returns the attributes as a simple set of key value pairs
    return @attr_set if (@attr_set)
    @attr_set = Set.new
    
    self.pmodules.each do |pm|
      @attr_set.merge(pm.attributes_as_set)
    end
    
    return @attr_set
  end

  def all_keys_as_set
    # returns the attributes as a simple set of key value pairs
    return @attr_keyset if (@attr_set)
    @attr_keyset = Set.new
    
    self.pmodules.each do |pm|
      @attr_keyset.merge(pm.keys_as_set)
    end
    
    return @attr_keyset
  end
  
  #
  # Need another set, that given a set of modules.
  # tells the attributes in common for that set of modules
  def get_attributes_as_set_for_modules_set(mod_set)
    rset = Set.new
    
    self.pmodules.each do |pm|
      next if (not mod_set.include?(pm.modname_id) )
      
      rset.merge(pm.attributes_as_set)
    end
    
    return rset
  end
  
  
  def load_from_string(input )
    #ObjectSpace
    self.raw = input
    self.md5_hash = Digest::MD5.hexdigest(input)
    self.save
    self.reload
    
    self.load_from_php_info( PhpinfoParser.parse_string(input))
  end
  
  
  def load_from_php_info(obj, clear = true)
    #
    # loads an object's config from a PHPObject:
    # 
    if(clear)
      self.clear
    end
    
    obj.config.each do |sec|
      # add all the sections and the values to the DB objects


      if(sec.name == "Additional Modules")
        # add the additional modules
        # as modules


        sec.settings.each do |key,val|
          if(key != "Module Name")
            
            cm = Pmodule.create_by_name_and_pconfig_id(key, self.id)
            cm.save
            
            print key + " - additional module\n"
          end
        end

      else
        cm = Pmodule.create_by_name_and_pconfig_id(sec.name, self.id)
        cm.save
        
        p sec.name
        sec.settings.each do |key,val|
          # now add the settings to the cm
          print "\t#{key} => #{val.join('|')}\n"
          cm.add_attribute(key, val )

        end
      end  
    end
  end
  
  def self.create_from_php_info_obj(obj, site_id )
    #
    # Takes a PHPInfoObj
    #
    ph = PConfig.new
    ph.site_id = site_id
    ph.save
    ph.reload   # just so we have an ID -- might not need
    
    ph.load_from_php_info(obj)

    return ph
  end # end create from obj


  
  def self.compare_group(infos)
    # given a bunch of phpinfos
    # return what all of them have in common
    
    mods_incommon = nil
    attrs_incommon = nil
    
    info.each do |inn|
      mods_incommon  = inn.modules_as_set if(!mods_incommon)
      attrs_incommon = all_attributes_as_set if(!attrs_incommon)
      
      mods_incommon  = mods_incommon & inn.modules_as_set
      attrs_incommon = attrs_incommon & all_attributes_as_set
      
    end
    
    return {
      :mods_incommon => mods_incommon,
      :attrs_incommon => attrs_incommon
    }
  end


  #
  # Get's common sets for an object
  #
  def get_common_sets(force = false)
    cc = CompareCache.find_by_pconfig_id(self.id)
    if(cc && !force)
      return Pconfig._hash_to_sets(YAML.load(cc.data))
    end
    cc = CompareCache.new
    cc.pconfig_id = self.id
    ret = {
      :modules_as_set => self.modules_as_set,
      :all_attributes_as_set => self.all_attributes_as_set,
    }
    cc.data = ret.to_yaml 
    cc.save
    
    return 
  end

  #
  # I need some method of comparing, two Sites.
  #
  # and calculating a fingerprint.
  # and calculating a similarity,
  # and calculating a difference
  
  
  
  def self.compare(php1, php2, from_cache = true)
    # takes two phpinfos
    # and computes what they have in common.
    #
    # So all of this works for a binary comparison.
    # what if I want to compare a group of PHP INFOs to each other?
    # looks like a job for 'another function', yet again, 'another function' saves the day!
    
    #
    # Eventually I will have a LARGE cache of all this information sitting somewhere
    # so I don't have to recalculate it everytime.
    
    #php1.modules_as_set
    #php2.modules_as_set
    
    mods_incommon = php2.modules_as_set & php1.modules_as_set
    
    mods_diff     = php2.modules_as_set ^ php1.modules_as_set

    
    a1 = php1.get_attributes_as_set_for_modules_set( mods_incommon )
    a2 = php2.get_attributes_as_set_for_modules_set( mods_incommon )    
    
    attrs_incommon  = a1 & a2
    attrs_diff      = a1 ^ a2 
    
    
    # get list of keys in common from ATTRS in common
    keys_incommon = Pconfig._key_val_set_to_keys(attrs_incommon)
    keys_diff     = Pconfig._key_val_set_to_keys(attrs_diff)    
    
    
    real_keys_diff     = php1.all_keys_as_set ^ php2.all_keys_as_set
    real_keys_diff_a   = real_keys_diff  & php1.all_keys_as_set
    real_keys_diff_b   = real_keys_diff  & php2.all_keys_as_set
    
    # so what would jaccard similaritiy look like
    # for these two things.
    #
    attrs_jaccard = (attrs_incommon.size.to_f / ( (a1 | a2).size ) )
    mods_jaccard = (mods_incommon.size.to_f / (php2.modules_as_set | php1.modules_as_set).size )    
    
    
    #
    # ok, let's go for lada's number :-)
    #
    # for mods:
    
    
    #
    # These need to be reworked, to be aware of what module the key/values are in
    # especially if this is suppose to be generic enough to work with other configurations.
    #
    
    mods_lada  = Pconfig._lada_number(mods_incommon, FreqMan )
    
    keys_lada  = Pconfig._lada_number(keys_incommon, FreqMan ) 
    attrs_lada = Pconfig._lada_number(attrs_incommon, FreqMan ) 
        
    
    return {
            :mods_incommon    => mods_incommon, 
            :mods_diff        => mods_diff,
            :mods_diff_a      => mods_diff & php1.modules_as_set,
            :mods_diff_b      => mods_diff & php2.modules_as_set,

            :mods_jaccard     => mods_jaccard ,
            :attrs_incommon   => attrs_incommon,
            :attrs_diff       => attrs_diff,
            :attrs_diff_a     => attrs_diff & a1,
            :attrs_diff_b     => attrs_diff & a2,
            :attrs_jaccard    => attrs_jaccard,
            
            :keys_diff      => keys_diff,    
            :keys_incommon  => keys_incommon,
            
            :real_keys_diff => real_keys_diff,
            :real_keys_diff_a => real_keys_diff_a,
            :real_keys_diff_b => real_keys_diff_b,
            
            
            :mods_lada  => mods_lada,
            :keys_lada  => keys_lada,
            :attrs_lada => attrs_lada

      }
  end


  def get_from_str(str)
    # takes an object similar to the freq_man, looks it up
    # given a string
    # return the right key for it
    if(str.class == Fixnum)
      return self.pmodules.find_by_modname_id( str )
    end
    
    parts = str.split("|")
    
    parts.map! do |j|
      j = nil if(j == "")
      j &&= j.to_i
      j
    end
    
    return self.get_attr(parts[0], parts[1])
  end

  # compare me with another php_info file
  def compare_to(php2)
    Pconfig.compare(self, php2)
  end

  def self._array_to_sets(hsh)
    # a very special case function
    # takes a hash of arrays, convert it to a hash of sets
    
    hsh.each do |k|
      hsh[k] = set(hsh[k])
    end
    return hsh
  end

  def self._hash_to_sets(hsh)
    # a very special case function
    # takes a hash of arrays, convert it to a hash of sets
    
    hsh.keys.each do |k|
      hsh[k] = set(hsh[k])
    end
    return hsh
  end
  


  #
  # I probably want to ditch this.
  #
  def self._key_val_set_to_keys(kvset)
    # little helper function
    # takes a set of key_vals.. and returns list of keys
    ret_set = Set.new
    kvset.each do |k|
      (mod,kk,v) = k.split("|",3)
      ret_set << (mod + "|" + kk)
    end
    return ret_set
  end
  
  def self._lada_number(st, freqman)
    ret = 0
    st.each do |r|
      freq = freqman.get_freq_from_str( r )
      if(!freq)
        p "NO FREQUNECY:"
        p freq
        p r
      elsif(freq < 2)
        p "-------------------------------------------------------------------------------------WTF"
        #p st
        p r
        p freq
        p "Why is this less than 2"
        #ret += 1
      else
        ret += 1.0/log(freq) #/log(2))
      end
    end 
    
    # Math.log(val)/Math.log(base)
    #sum([1/log(freq) for freq in freqs]
    return ret
  end
  
  
  def get_attr(name, key)
    #p "ARGS:"
    #p name
    #p key

    #
    # Get an Attribute.
    #
    @smart_hash || self.build_smart_hash
    
    #p @smart_hash[name]
    #p @smart_hash[name][key]
        
    if(!@smart_hash[name])
      return nil
    end
    
    return @smart_hash[name][key]
    
  end
  
  def build_smart_hash
    # memory intensive :-)
    @smart_hash = {}
    self.pmodules.each do |pm|
      @smart_hash[pm.modname_id] ||= {}
      pm.pattributes.each do |pa|
        @smart_hash[pm.modname_id][pa.pkey_id] = pa
      end
    end
  end
  
  def self.hash_to_json(hsh)
    hsh.keys.each do |k|
      hsh[k] = hsh[k].to_a if(hsh[k].class == Set)
    end
    return hsh.to_yaml
  end
  
  
  #
  # returns either the cached version or creates a new cached version.
  #
  def self.compare_and_cache(php1, php2, force = false, fast = false)
    if(php1.id > php2.id)
      # in, is always smaller
      _php_tmp = php1
      php1 = php2
      php2 = _php_tmp
    end
      
    in_id = php1.id
    out_id = php2.id
    
    
    if(fast)
      ce = CompareEdge.find(:first, :select => "id", :conditions => ["in_id = :in_id and out_id = :out_id", {:in_id => in_id, :out_id => out_id}]) 
      return ce if (ce) 
    else
      ce = CompareEdge.find(:first, :conditions => ["in_id = :in_id and out_id = :out_id", {:in_id => in_id, :out_id => out_id}])
    end
    
    if(!ce or force)
      com  = Pconfig.compare(php1,php2)
      if(!ce)
        ce = CompareEdge.new
        ce.in_id = in_id
        ce.out_id = out_id
      end
      
      begin
        ce.cache  = com.to_yaml
      rescue
        p com
        p $!
        print $@.join("\n")

        raise Exception.new("Huh")
      end
      if(com[:mods_jaccard].to_s == 'NaN' or com[:mods_jaccard].to_s == "nan")
        com[:mods_jaccard] = -1
      end
      if(com[:attrs_jaccard].to_s == 'NaN' or com[:attrs_jaccard].to_s == "nan" )
        com[:attrs_jaccard] = -1
      end
      
      ce.mods_jaccard = com[:mods_jaccard]
      ce.attr_jaccard = com[:attrs_jaccard]

      ce.save
      #p com[:mods_jaccard]
      #p com[:attrs_jaccard]
      p "saved"
      return com
    end
    
    return Pconfig._hash_to_sets(YAML.load(ce.cache) )
    
  end
  
  def compare_with_all()
    # compares this PHP with all the others
    ret = Pconfig.find(:all)
    
    ret.each do |j|
      print "Compared: #{self.id} with #{j.id}\n"
      Pconfig.compare_and_cache(self, j , false, true)  # force = false, fast = true
    end
  
  end
  
  
  def self.compare_all()
    #
    # compare everything with everything else, being mindful of stuff that's already been compared.
    # this will probably kill the memory. and be super slow.
    ret = Pconfig.find(:all)
    
    ret.each do |i|
      i.compare_with_all()
    end
    
  end
  
  
  #
  # all of my new work hinges on this :-)
  #
  # So the basic idea is that, I might have a nice Normal form DB, but that is making my queries
  # super complex, when really they could be a lot nicer, if I was using a nice view table :-)
  #  http://dev.mysql.com/doc/refman/5.0/en/create-view.html
  # Also.. 

  
end # end the class


%{
graphAdamic(g,a,b,mode):
"""returns the Adamic-Adar coefficient of two nodes"""
aN = set(g.neighbors(a,type=mode))
bN = set(g.neighbors(b,type=mode))
both = list(aN.intersection(bN))
freqs = g.degree(both,type=mode)

return sum([1/log(freq) for freq in freqs])
}


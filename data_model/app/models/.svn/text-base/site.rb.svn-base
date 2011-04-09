 require 'set'
 
class Site < ActiveRecord::Base
  has_many :cattributes
  has_many :cmodules
  
  
  def display()
    # prints a site out nicely
    print "id: #{id}\n"
    print "url: #{url}\n"
    print "query: #{query}\n"
    print "path: #{path}\n"
    print "MODULES:\n"
    self.cmodules.each do |cm|
      print cm.name + "\n"
      #cm.cattributes.each do |ca|
      #  print "\t" + ca.key + " = " + ca.val + "\n"  
      #end  
    end
    
  end
  
  def diff(s1)
    # determines the difference between self, and s1
    return recursive_diff(self.to_hash, s1.to_hash )
  end
 
  def modules_as_set()
    ms = Set.new
    
    self.cmodules.each do |cm|
      ms.add(cm.name)
    end
    return ms
  end

  def module_diff(s1)
    mine = self.modules_as_set
    his  = s1.modules_as_set
    return mine ^ his
  end
  
  def recursive_diff(s1, s2)
    dff = Hash.new
    if(s1.class == s2.class and s1.class == Hash)
      # do the loop
      seen = Hash.new
      s1.keys.each do |k|
        ret = recursive_diff( s1[k], s2[k] )
        if(ret)
          dff[k] = ret
        end
        seen[k] = 1
      end
      
      s2.keys.each do |k|
        next if (seen[k])
        ret = recursive_diff( s1[k], s2[k] )
        if(ret)
          dff[k] = ret
        end
      end
      return dff
    else
      s1 ||= ""
      s2 ||= ""
      if(s1 != s2)
        return s1.to_s + "  |  "+ s2.to_s
      end
        return nil
    end
    
  end
  
  def to_hash()
    # returns a hash representation of the site
    q = Hash.new
    q['attributes'] = Hash.new
    q['modules'] = Hash.new
    self.cmodules.each do |cm|
      q['modules'][cm.name] = cm.name

      #q['modules'][cm.name] = Hash.new
      #cm.cattributes.each do |ca|
      #  q['modules'][cm.name][ca.key] = ca.val 
      #end  
    end
    
    return q
  end
end

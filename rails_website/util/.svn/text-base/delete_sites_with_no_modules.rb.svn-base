#
# Find and delete sites that have no modules.
#



Pconfig.find(:all).each do |r|
  
  if(!r.site || r.site_id == nil )
    r.pmodules.each do |j|
      Pmodule.delete(j)
    end
    p "deleting Pconfig #{r.id}"
    Pconfig.delete(r)
  end
  
  
end

Site.find(:all).each do |s|
  if(s.pconfigs.size ==0)
    Site.delete(s)
    print "deleted #{s.host} (#{s.id})"
  end
end
require 'time'
# running in rails environment

_start = Time.now.to_f
relations = Hash.new
Cmodule.find(:all).each do |mod|
  relations[mod.name] ||= Array.new
  relations[mod.name] << mod.site_id
end

# now add a ton of edges:
relations.keys.each do |k|
  relations[k].each do |item|
    relations[k].each do |in_item|
      next if (in_item == item)
      
      me = Medge.new
      me.in_site_id = item
      me.out_site_id = in_item
      me.description = k
      me.save
      
    end
  end
end

print "Finished in: #{Time.now.to_f - _start}\n"
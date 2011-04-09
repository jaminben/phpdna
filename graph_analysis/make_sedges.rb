require 'time'
require 'db.rb'
# running in rails environment
require 'app/models/cmodule.rb'
require 'app/models/sedge.rb'

_start = Time.now.to_f
relations = Hash.new
Cmodule.find(:all).each do |mod|
  relations[mod.name] ||= Array.new
  relations[mod.name] << mod.site_id
end

#
##
# I am sure I can do this faster
#


GC.start

_similar = Hash.new

# now add a ton of edges:
relations.keys.each do |k|
  p k,relations[k].size
  c = 0
  relations[k].each do |item|
    relations[k].each do |in_item|
      next if (in_item == item)
      
      _similar["#{item}.#{in_item}"] ||= 0 
      _similar["#{item}.#{in_item}"] += 1 
      #print "."
      c +=1
    end
    print "#{relations[k].size * relations[k].size - c}\n"
  end
end

_similar.keys.each do |k|
      p k, _similar[k]
      (item, in_item) = k.split(".")
      me = Sedge.new
      me.in_site_id = item.to_i
      me.out_site_id = in_item.to_i
      me.common = _similar[k]
      me.save
end 

print "Finished in: #{Time.now.to_f - _start}\n"

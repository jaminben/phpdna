require 'time'
# running in rails environment

print ARGV

s  = Site.find_by_id ARGV[0]
s1 = Site.find_by_id ARGV[1]

m1 = s.modules_as_set
m2 = s1.modules_as_set

print "URLS:\n"
p s.url
p s1.url
print "MODULES"
p m1
p m2
print "SIMILAR\n"
p m1 & m2
print "DIFF\n"
print m1 ^ m2
 


def print_hash(h, level = 0)
  h.keys.each do |k|
    if(h[k].class == Hash)
      print_hash(h[k], level +1 )
    else
      c = 0
      while(c < level)
        print "\t"
        c+=1
      end
      print k + "-> " + h[k] + "\n"
    end
  end
end

#h =  s.diff(s1)

#print_hash(h)

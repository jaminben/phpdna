#
# Simple test of configFlat to make sure we are getting the right values
# from the frequency queries
#
type = nil

def assert(a)
  return true if(a)
  raise Exception.new("ERROR ON ASSERT")
end


def compare(a,b, key)
  a.keys.each do |k|
    assert (a[k][key] == b[k][key] )
    if a[k][key] == b[k][key]
      #p "good"
    else
      p "#{a[k][key]} --> #{b[k][key]}"
    end

  end
end


def compare2(a,b, key)
  a.keys.each do |k|
    next if (k.class == Symbol)
    a[k].keys.each do |j|
      next if (j.class == Symbol)
      #assert (a[k][key] == b[k][key] )
      if a[k][j][key] == b[k][j][key]
        #p "good"
      else
        p "#{a[k][key]} --> #{b[k][key]}"
      end
    end
  end
end

a = PconfigFlat.get_mod_frequency(type)  
PconfigFlat.calcute_distribution(a)

b = PconfigFlat.get_key_frequency(type)  
PconfigFlat.calcute_distribution(b)

c = PconfigFlat.get_key_val_frequency(type)  
PconfigFlat.calcute_distribution(c)

#
# ok now I need to check that mcount is the same
#

p a[:max_mcount] 
p b[:max_mcount] 
p c[:max_mcount]

# check modules
assert(a[:max_mcount] == b[:max_mcount])
assert(b[:max_mcount] == c[:max_mcount])

compare(a,b, :mcount)
compare(b,c, :mcount)

compare2(b,c, :sum)

# nice
# assuming, I trust the values I am getting
# everything should be good.





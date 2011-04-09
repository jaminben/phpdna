require 'rubygems'
require 'hpricot'
require 'json'
require 'time'

# I'll probably want objects to take care of storing modules
# and key value pairs associated with
#
#
#
# what should my objects look like anyway?
#
#
# Ok stuff to do.
#
# Crawler
#  * Parent Object to Store all this stuff
#  * 
#
#
#
#

# ok.. all thread safety is handled by the database!
# essentially we call this command with the path to the file we are parsing.


# The code may be ugly.
# but it seems to do the job.

_start = Time.now.to_f

if(ARGV[0] == '' or ! ARGV[0])
  p "Must specify a file to parse"
  exit
end


# Should we show extra output
DEBUG = false


  
class PHPConfigSection
  attr_accessor :settings, :name
  
  def initialize(name = "no name")
    @settings = Hash.new  
    @name = name
  end
  
  def add_setting(key,val, distinct =true)
    @settings[key] ||= Array.new
    if(not distinct or @settings[key].length == 0 or not @settings[key].index(val) )
      # make sure we only add distinct values.. i.e. don't worry about master/non master
      # unless the values are different. -- this is probably a PHP special case as well
      #
      @settings[key] << val  
    end
  end
  
end



def parse_and_save(file_name )
  php_config = Array.new

  input = File.open(file_name)

  parts = input.read.split("<h2>")

  top = parts.shift
  parts.pop

  # if we got here we were able to open the file.
  s = Site.find_by_path(file_name)

  if(s)
    p "Site has already been processed: #{file_name}"
    return false
  end

  my_site = Site.new
  my_site.path = file_name

  # ok check the top for the config options
  if(top =~ /\|\-\|/)
    # ok.. we should be able to parse out more data
    (front,middle,back) = top.split("|-|")
    info = JSON.parse(middle)
    my_site.query  = info["query"]
    my_site.url    = info["url"]
  end

  # ok save the site
  p my_site
  my_site.save
  my_site.reload
  
  
  # the top is a little funky so deal with it seperately
  sec = PHPConfigSection.new('head') 
  doc = Hpricot(top)

  version = doc.search("h1")[0].innerHTML
  zend = doc.search("table").last.search("td").innerHTML

  if(zend)
    if(zend =~ /\d\.\d\.\d/)
      sec.add_setting("zend_version", $&)
    end
    
  end
  sec.add_setting("version", version)
  sec.add_setting("zend", zend)


  doc.search("table")[1].search("//tr").each do |tr|
    key =  tr.children[0].innerHTML
    
    tr.children.shift
    if(tr.children.size > 0)
      key = key.strip
      tr.children.each do |c|

        val =  c.innerHTML
        if(val.strip == "<i>no value</i>")
          val = nil
        end
        
        val = val.gsub(/<\/?[^>]*>/, "").strip if (val)
        
        if(DEBUG)
          p "#{key} => #{val}" 
        end
        sec.add_setting(key,val)
      end
    elsif(key)
      key = key.strip
      sec.add_setting(key,"")    
    end
  end
 
  php_config << sec



  parts.each do |block|
    section = block.match(/[^<]+/)[0]
  
    if(section =~ /module_/)
      section = block.match(/name=\"([^\"]+)\"/)[1]
    end
    sec = PHPConfigSection.new(section) 
    p section if(DEBUG)
  
    doc = Hpricot(block)
    doc.search("//tr").each do |tr|
      key =  tr.children[0].innerHTML
      tr.children.shift
      if(tr.children.size > 0)
        key = key.strip
        
        tr.children.each do |c|
          val =  c.innerHTML
          if(val.strip == "<i>no value</i>")
            val = nil
          end
          
          val = val.gsub(/<\/?[^>]*>/, "").strip if (val)
          if(DEBUG)
            p "#{key} => #{val}" 
          end
          sec.add_setting(key,val, true)
        end
      elsif(key)
        key = key.strip
        sec.add_setting(key,"", true)    
      end
    end
    # add section
    php_config << sec
  end

  #
  # The resulting config is:
  # 
  php_config.each do |sec|
    # add all the sections and the values to the DB objects

  
    if(sec.name == "Additional Modules")
      # add the additional modules
      # as modules

      
      sec.settings.each do |key,val|
        if(key != "Module Name")
          cm = Cmodule.new
          cm.site_id = my_site.id
          cm.name = key
          cm.save
          print key + " - additional module\n"
        end
      end
      
    else
      cm = Cmodule.new
      cm.site_id = my_site.id
      cm.name = sec.name
      cm.save
      
      p sec.name
      sec.settings.each do |key,val|
        # now add the settings to the cm
        cm.add_attribute(key, val.join('|') )
        print "\t#{key} => #{val.join('|')}\n"
      end
    end  
  end
  return true
end # end function


# do the real work
c = 0
ARGV.each do |file_name|
  p "Parsing and saving #{file_name}"
  good = false
  begin
    good = parse_and_save(file_name)
    c +=1 if(good)
  rescue
    p $!
    p $@.join("\n")
  end
end
  
print "Processed #{c} record(s) in #{Time.now.to_f - _start} seconds\n"



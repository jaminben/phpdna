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



# Should we show extra output
DEBUG = false

def clean(str)
  str.gsub("&nbsp;", " ").gsub("&quot;",'"').gsub(/<[^\>]*>/, "").strip 
end

  
class PHPConfigSection
  attr_accessor :settings, :name
  
  def initialize(name = "no name")
    @settings = Hash.new  
    @name = name
  end
  
  def add_setting(key,val, distinct =true)
    # let's clean up the values:
    # clean up values
    @settings[key] ||= Array.new
      
    if((distinct and (! @settings[key].include? val) ) or !distinct )
      @settings[key] << val  
    end
    
  end
  

  
end


# keys that are probably not all
# that useful, and throw off fingerprints

FILTER_KEYS = [
  '_SERVER["REMOTE_ADDR"]',
  
  
  ]

class PhpinfoObject
  #
  # hmm.. seems to serve pretty much no purpose :-)
  #
  attr_accessor :config
  
  def initialize
    @config = Array.new
  end
  
  def fingerprint
    #
    # ahh.. the fingerprinter.
    #
    # somehow figures out.. what a unqiue fingerprint is
    
  end
  
end


class PhpinfoParser
  def self.parse_file(filename)
    return ObjectSpace.parse_string(File.open(file_name).read)
  end
  
  def self.parse_string(input)
    _start = Time.now.to_f
    
    #
    # Parses a PHP Config
    # and returns a PhpinfoObject
    #
    php = PhpinfoObject.new
    
    parts = input.split(/\<h2[^\>]*\>/i)

    top = parts.shift
    # what does this do.. ?
    #parts.pop  
    # parts are

    p parts.size
    
    
    my_site = Site.new
    
    # the top is a little funky so deal with it seperately
    sec = PHPConfigSection.new('head') 
    doc = Hpricot(top)
    
    # this will break if it's an invalid PHP INFO file.
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
        key = clean(key) if (key)
        tr.children.each do |c|

          val =  c.innerHTML
          if(val.strip == "<i>no value</i>")
            val = nil
          end

          val = clean(val) if (val)
          
          if(DEBUG)
            p "#{key} => #{val}" 
          end
          sec.add_setting(key,val)
        end # end loop
      elsif(key)
        key = key.strip
        sec.add_setting(key,"")    
      end
    end

    
    
    php.config << sec

    parts.each do |block|

      section = block.match(/[^<]+/)[0]

      if(section =~ /module_/i)
        section = block.match(/name=\"([^\"]+)\"/i)[1]
      end
      sec = PHPConfigSection.new(section.strip) 
      p section if(DEBUG)

      doc = Hpricot(block)
      doc.search("//tr").each do |tr|
        key =  tr.children[0].innerHTML
        tr.children.shift
        if(tr.children.size > 0)
          key = clean(key) if (key)

          tr.children.each do |c|
            val =  c.innerHTML
            if(val.strip == "<i>no value</i>")
              val = nil
            end

            val = clean(val) if (val)
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
      php.config << sec
    end
    
    if(DEBUG)
      print "Processed in #{Time.now.to_f - _start = Time.now.to_f} seconds "
    end

    return php
  end # end function
    
end





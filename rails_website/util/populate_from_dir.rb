#
# Need to be called using
# ./script/console
#
# or 
# ./script/runner
#
#
# a simple script to import the data from the existing PHP INFO files
# 
# with some more cleaning than I've done in the past.
#
# 
require 'rubygems'
require 'json'
require 'cgi'

PATTERN = "*segapoto.com_"
PATTERN = "*"

ARGV[0] ||= "../php/php_info/"

if(! ARGV[0])
  print "Must specify a path to the directory to load\n"
  exit(1)
end

Dir.glob(ARGV[0] + PATTERN).each do |file|
  next if (! File.file? file )
  contents = open(file).read
  p file
  
  # ok check the top for the config options
  if(contents =~ /\|\-\|/)
    # ok.. we should be able to parse out more data
    (front, contents) = contents.split("|-| -->", 2)
    (front,middle, extra) = front.split("|-|")
    info = JSON.parse(middle)
    # :url
  
    # ignore those without a URL for obvious reasons?
    p info['url']
    
    if(info['url'] =~ /yahoo/)
      # need to clean it up
      parts = info['url'].split(/http/)
      info['url'] = "http" + CGI.unescape(parts.last)
    end
    
    p info['url']    
    # now 
    begin
      s = Site.create_or_get_from_url(info['url'], true)
    rescue
      p $!
      print $@.join("\n")
      next
    end
    
    if(s)
      begin 
        s.load_from_string(contents)
      rescue Exception
        #p contents
        p "caught it here -- top one"
        p $!
        print $@.join("\n")
        
        #delete it.
        Site.delete(s)
      rescue
        #p contents
        p "caught it here"
        p $!
        print $@.join("\n")
        
        #delete it.
        Site.delete(s)
      end
    else
      print "already in there!\n"
    end
    
  end
  
  
end

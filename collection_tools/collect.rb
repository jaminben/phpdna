require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'cgi'
require 'time'
require 'threadpool'
require 'thread'
require 'json'
require 'openssl'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

API_KEY='pezYFOzV34EXsj5_mta8JABWIYx19c4RsB6gwxEl56ZSVGoaAtb11yLAjJO8VZ2v'
OUTPUT_DIR = "raw_phpinfo_files/"
BUFFER_SIZE = 4096

def convert_to_hash(str, query)
  doc = Hpricot(str)
  res = Array.new

  i =0
  doc.search("//result").each do |e|

    item = Hash.new
    item[:title]   = e.search("title").innerHTML
    item[:url]     = e.search("clickurl").innerHTML
    item[:summary] = e.search("summary").innerHTML if( e.search("summary").innerHTML !~ /\</)
    item[:rank]    = (i+=1)
    item[:query]   = query        # to search other countries etc..
    
    res << item

  end

  return res
end


def search(query, start =0, results = 100, extra = '')
  if(start + results > 1001)
    print "API WON't let you search for more than 1000 records "
    return []
  end
  begin
    query = CGI.escape(query)
    url = "http://api.search.yahoo.com/WebSearchService/V1/webSearch?appid=#{API_KEY}&query=#{query}&start=#{start}&results=#{results}" + extra
    print "#{url}"
    data =  open(url).read
    return convert_to_hash( data, url)
  rescue
    p $!
    p $@.join("\n")
    return []
  end
end

# I see this as sort of a multi-threaded method of grabing a bunch of PHPINFO files, and naming them based on their location
#  N + 1 threads
# 1 COLLECTOR.
# 1 distributor

def url_to_safe(url)
  return url.gsub(/[\/\"\'\&]/,"_")
end


# make some threads



#incremenal search
def incremental_search(query, start, endd, callback_class, extra ='')
  i=start
  res = []
  while(i<endd)
    search(query, i, 100, extra).each do |item|
      callback_class.process(item)
    end
    i += 100
  end
end

class ProcessItem
  def initialize
    @@count ||= 0
    @@threadpool ||= ThreadPool.new(100)
    @@queue ||= Queue.new
  end
  def process(item)
    # see if we already have it
    if( ! File.exists?(File.join(OUTPUT_DIR, url_to_safe(item[:url] ))))
      # file doesn't exist, so I need to grab it
      if( @@threadpool.find_available_worker  )
        print "CALLED PROCESS"
        @@threadpool.process {
          
          # process a block of code in a new thread, in my case.. download the file.
          begin
            self.thread_process( item )
          rescue
            p $!
            print $@.join("\n")
          end
          
        }
      else
        # push it in the QUEUE.
        # 
        p "ITEM ADDED TO QUEUE"
        @@queue.push(item)
      end
      
      p item[:summary]
      p url_to_safe(item[:url])
      p @@count +=1
      
    else
      # we already have this file
      print "Already downloaded #{item[:url]}\n"  
    end
    

    
  end
  
  
  def thread_process(item)
    # process an item, and then see if more are waiting.
    # then process them or exit.
    cont = true
    while(cont)
      # ok we should have a variable called 'item'
      # to deal with here :-)
      begin
        # get it.. into 
        file_to_get = File.join(OUTPUT_DIR, url_to_safe(item[:url] ))
        buffer = ''
        p "DOWNLOADING FILE"
        
        open(item[:url]) do |f|
          open(file_to_get , "wb") do |file|
            # write header information
            file.write(%{ <!-- Header |-|#{item.to_json}|-| -->})
              
            while(f.read(BUFFER_SIZE,buffer))
              file.write(buffer)
            end
          end
        end
        print "FILE_SAVED"
      rescue
        p $!
        p $@
      end
      
      
      
      begin
        item = @@queue.pop(True)
        cont = true
      rescue
        cont = false
      end
    end
    
  end
  
  def threadpool
    return @@threadpool
  end
  
end

pi = ProcessItem.new
#

#extra = "&region=uk"
#extra = "&region=ru"
#extra = "&region=fr"
#extra = "&region=es"
extra = "&region=sg"

incremental_search('"phpinfo()" "PHP Core"',0, 10000, pi, extra )

print "WAITING FOR FILES TO FINISH DOWNLOADING"
pi.threadpool.join()


  
  

require 'digest/md5'
require 'open-uri'
require 'uri'
require 'socket'

class Site < ActiveRecord::Base
  has_many :pconfigs #, :select => ‘id, site_id, md5_hash, created_at, updated_at’
                     # does this work.

  
  def self.create_or_get_from_url(url, check_ip = false)
    #
    # Downloads a URL / parses it, and places it into the database, Ha!
    #

    # does the site already exist?
    s = Site.find_by_url(url)
    return s if(s)

    uri = URI::parse(url)
    ip = IPSocket::getaddress(uri.host)
    
    #
    # check to see it's from a unique host
    # (not all that useful I guess -- hmm.. varies)
    # 
    if(check_ip)
      s = Site.find_by_ip_address(ip)
      return s if(s)
    end

    #
    # Ok ,at this point it's a unique IP address.. so we are fine.
    #

    site = Site.new
    site.url         = url
    site.host        = uri.host
    site.ip_address  = ip
    site.save
    site.reload
    
  end
  
  
  def load_from_string(input)
    md5 = Digest::MD5.hexdigest(input)
    
    # first see if a phpinfo with this md5sum exists.
    # I don't think this will ever happen
    pp = self.pconfigs.find_by_md5_hash(md5)
    return pp if (pp)
  
  
    begin
      # otherwise, create a new one
      pp = Pconfig.new
      pp.site_id = self.id
      pp.save
      pp.reload
      pp.load_from_string(input)
    
      # duh, the most recent is going to be current
      pp.set_current
      
    rescue
      # clean pmodules
      pp.pmodules.each do |pm|
        Pmodules.delete(pm)
      end
      
      Pconfig.delete(pp)
      raise Exception.new("Error parsing")
    end
    

    
    return pp
  end

  def reload_url()
    # relaods the url
    return self.load_from_url(self.url)
  end

  def load_from_url(url)
    # loads a PHP file from a URL.
    return self.load_from_string( open(url).read )
  end
    
  
end

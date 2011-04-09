require 'open-uri'
require 'openssl'

module OpenSSL
  module SSL
    class SSLSocket
      def post_connection_check(peer_cert, hostname = true)
        return true
      end
    end
  end
end


class Float
  def to_s(places = 2)
    #force all Floats to 2 decimal places
    "%.#{places}f" % self
  end
end


class SitesController < ApplicationController
  # GET /sites
  # GET /sites.xml
  caches_page :phpinfo
  caches_page :compare
  
  
  
  #
  # This is really for everything
  #
  def index
    #@sites = Site.find(:all)
    
    #count sites
    @stats_total = Site.count_by_sql("SELECT COUNT(*) FROM sites")
    
    # count modules
    @stats_mods = Pmodule.count_by_sql("SELECT COUNT(*) FROM modnames")
    
    #count attributes
    @stats_attributes_key = Pattribute.count_by_sql("SELECT COUNT(*) FROM pvalues")
    @stats_attributes_val = Pattribute.count_by_sql("SELECT COUNT(*) FROM pkeys")

    @recent = Pconfig.find(:all, :limit => 10, :order => "created_at DESC")
    
    
  end

  
  #
  # 
  # view information
  # 
  # I need to add another controller, that let's you browse by these 1 to 1 comparisons.
  # i.e. I click on a value, and it shows a list of sites with a similar value..
  # as well as their similarities (in a matrix?)
  #
  # it would be cool to have a way of graphing these histograms.
  #
  # implement view_by_value..   really I guess I just need some sort of site matrix.
  #
  # I also need to make the frequency calculation for the KV pairs, aware of which module
  # the frequency is for.
  #
  # It also would be fun for the comparison page.. to show values that the WITH portion is not in common with.
  #



  # GET /sites/1
  # GET /sites/1.xml
  def show
    @site = Site.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @site }
    end
  end

  def compare
    # id is who we are comparing
    # other = remote id
    @php1 = Pconfig.find_by_id params[:id]
    @php2 = Pconfig.find_by_id params[:with]
    
    @compare = Pconfig.compare(@php1, @php2)
    
    # I need to do some lookups
    # take the arrays of things, and convert them into
    # objects.


  end
  
  def phpinfo
    # just display one of them :-)
    @php = Pconfig.find_by_id params[:id]
    
    #
    # This can probably be rolled into the Phpconfig class
    # 
    @near = CompareEdge.find(:all, :conditions => ['in_id = :in_id or out_id = :in_id', {:in_id => params[:id]}], :order => "mods_jaccard DESC", :limit => 20) #, :include => ["get_out", "get_in"] )
 
    @far = CompareEdge.find(:all, :conditions => ['in_id = :in_id or out_id = :in_id and mods_jaccard > 0.01', {:in_id => params[:id]}], :order => "mods_jaccard ASC", :limit => 20) #, :include => ["get_out", "get_in"] )

    @near_attr = CompareEdge.find(:all, :conditions => ['in_id = :in_id or out_id = :in_id', {:in_id => params[:id]}], :order => "attr_jaccard DESC", :limit => 20) #, :include => ["get_out", "get_in"] )
 
    @far_attr = CompareEdge.find(:all, :conditions => ['in_id = :in_id or out_id = :in_id and attr_jaccard > 0.01', {:in_id => params[:id]}], :order => "attr_jaccard ASC", :limit => 20) #, :include => ["get_out", "get_in"] )

 
    # load the frequency.
    FreqMan.get_key_val_distribution(nil)
  
  end

  def pretty_phpinfo
    phpinfo
    
  end
  
  
  def add
    @error = nil
    @s = nil
    @pp = nil
    @already_added  = false
     
    # adds a PHP INFO
    # IF it seems legit.
    
    # fix the URL if it doesn't have a http://
    params['url'] = params['url'].strip
    if(!params['url'].match(/^https*\:\/\//i))
      params['url'] = "http://" + params['url']
    end
    
    begin
      s = Site.find_by_url(params['url'])
      if(s  )
        @already_added = true
        @s  = s
        @pp = s.pconfigs.last  # most recent
        
      else
      
        print "connecting"
        contents = open(params['url']).read
        print "connected"
        s = Site.create_or_get_from_url(params['url'], true)
        print "got site.."
        @pp = s.load_from_string(contents)
        @pp.reload
        @pp.set_current   # now we can do this over time.. hehe.. that will be efficient-- not
        
        # compare it with everyone else :-) -- N time baby
        spawn do
          @pp.compare_with_all()
        end
        
        @s = s
      end
      
    rescue Exception
      p $!
      print $@.join("\n")
      @error = "Error  importing #{params['url']}"
    rescue
      p $!
      print $@.join("\n")
      @error = "Error  importing #{params['url']}"
    end
    
    respond_to do |format|
      format.html {
        if(@error)
          render :text => @error
        else
          render :text =>%{
                          <div class="success">
                            <p>Your PHP Info page has been analyzed and added to our repository! </p>
                            <p>The direct link to your page is:<br /> 
                              <a href="/phpinfo/#{@pp.id}">http://phpinfo.us/phpinfo/#{@pp.id}</a>
                            </p>
                          </div>
                          }
        end
      }
      format.xml {
        if(@error)
          render :xml => {:error =>@error, :success => false}
        else
          render :xml => {:success => true , :url => "http://phpinfo.us/phpinfo/#{@pp.id}" }
        end
      }
      
    end
  end

  # PUT /sites/1
  # PUT /sites/1.xml
  #def update
  #  @site = Site.find(params[:id])

  #  respond_to do |format|
  #    if @site.update_attributes(params[:site])
  #      flash[:notice] = 'Site was successfully updated.'
  #      format.html { redirect_to(@site) }
  #      format.xml  { head :ok }
  #    else
  #      format.html { render :action => "edit" }
  #      format.xml  { render :xml => @site.errors, :status => :unprocessable_entity }
  #    end
  #  end
  #end

  # DELETE /sites/1
  # DELETE /sites/1.xml
  #def destroy
  #  @site = Site.find(params[:id])
  #  @site.destroy

  #  respond_to do |format|
  #    format.html { redirect_to(sites_url) }
  #    format.xml  { head :ok }
  #  end
  #end
end

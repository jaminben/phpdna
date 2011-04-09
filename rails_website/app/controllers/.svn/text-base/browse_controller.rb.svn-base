class Float
  def to_s(places = 2)
    #force all Floats to 2 decimal places
    "%.#{places}f" % self
  end
end

class BrowseController < ApplicationController
  layout 'sites'
  caches_page :module
  #caches_page :compare

  
  def key
    @php1  = nil
    @php2  = nil
    FreqMan.get_key_val_distribution(nil)
    
    @php1 = Pconfig.find_by_id params[:me]   if(params[:me])
    @php2 = Pconfig.find_by_id params[:with] if(params[:with])
     
    sql = %{
     select pa.*
     from
      pmodules pm join 
      pattributes pa on  pm.id = pa.pmodule_id
     where
        pa.pkey_id = #{params[:id].to_i} and
        pm.modname_id = #{params[:pmodule].to_i}
      
    }
    print sql
    
    @pattr   = Pattribute.find_by_sql(sql).first
#    :first, :conditions=> {:pmodule_id => params[:pmodule], :pkey_id => params[:id]})
    
    #global co-occuring
    @co     = @pattr.cooccuring_keys( 0.7)
    @co_mod = @pattr.cooccuring_mod_keys( 0.95)
    # should have co-occuring in module as well.
    
    
  end


  #
  # Show all sites with that value.
  #
  def value
   sql = "select p.* from 
    pconfigs p join pmodules pm on pm.pconfig_id = p.id
    join pattributes pa on pa.pmodule_id = pm.id
    where 
        pm.modname_id = #{params[:pmodule].to_i} and
        pa.pvalue_id = #{params[:id].to_i} and
        pa.pkey_id   = #{params[:key].to_i}
    "
    print sql
    @sites = Phpinfo.find_by_sql(sql)
    
    @pattr   = Pattribute.find_by_sql(%{
     select pa.*
     from
        pmodules pm join 
        pattributes pa on  pm.id = pa.pmodule_id
     where
        pa.pkey_id    = #{params[:key].to_i}     and
        pm.modname_id = #{params[:pmodule].to_i} and
        pa.pvalue_id  = #{params[:id].to_i}      
    }).first
    
    
    
    @pmodule = @pattr.pmodule
    @value   = @pattr.pvalue
    @key     = @pattr.pkey
    
    
  
    #
    # Need to add this cohorts
    #
    @co = @pattr.cooccuring_key_val(0.9)
    @co_mod = @pattr.cooccuring_key_val_mod(0.95)

  end
  
  #
  # Give this module, find all the php info's using it.
  #
  def module
    if(params[:modname])
      params[:id] = Modname.find_by_modname(params[:modname]).id
    end
    
    FreqMan.get_key_distribution(nil)
    
    sql = "select p.* from 
            pconfigs p join pmodules pm on pm.pconfig_id = p.id
            where 
                pm.modname_id = #{params[:id].to_i}
            "    
    @sites   = Pconfig.find_by_sql(sql)
    @pmodule = Pmodule.find_by_modname_id params[:id]
    
    @co      = @pmodule.cooccuring_module_names(0.70) # cutoff
    
    if(params[:with])
      # if comparing with me.
      
    end
  end
  
end

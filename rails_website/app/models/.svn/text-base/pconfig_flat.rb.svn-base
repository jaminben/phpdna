class PconfigFlat
  #
  # This is a place to put all of those simple, SQL based calls that should be optimized, and put here.
  # i.e. run through the view
  @@view_name = %{pconfig_flat}  
  
  def self.generate_view(static = false)
    #
    # In the future you can imagine sites having more than one pconfig_id
    # we really want to limit this to the "most recent"
    # of each. -- meaning we may need a subselect. --- for now we can ignore this though.
    # however-- visualizing this stuff over time would be super cool!
    #
    sql = %{
      select 
          concat(pc.id, '-', pm.modname_id, '-', pa.pkey_id, '-', pa.pvalue_id, '-', ifnull(pa.pvalue_master_id,'') ) as id,
          pc.id as pconfig_id,
          pc.type as type,
          pc.current as current,
          pc.site_id as site_id,    
          pm.modname_id as modname_id,
          pa.pkey_id as pkey_id,
          pa.pvalue_id as pvalue_id,
          pa.pvalue_master_id as pvalue_master_id  
      from
        pconfigs pc
        join pmodules pm on pm.pconfig_id = pc.id
        left join pattributes pa on pa.pmodule_id = pm.id 
      
    }
    
    
    
    if(static)
      # create a static copy
      Pconfig.connection.execute(%{
        DROP TABLE #{@@view_name};
        CREATE TABLE #{@@view_name} as #{sql};  
      })
      # do I want indexes
    else
      # create a view
      Pconfig.connection.execute(%{
         CREATE OR REPLACE VIEW   #{@@view_name} as #{sql};
      })
    end
    
  end
  
  #
  # Get modules frequency
  #
  def self.get_mod_frequency(type = nil)
    ret = {:sum => 0,  :count => 0, :max => 0, :max_mcount => 0 }
  
    if(type == nil)
      ptype = "and type is null"  
    else
      ptype = "and type = '%s'" % (type)
    end

    sql = %{
      SELECT 
        r.modname_id,
        mn.modname,
        sum(r.count) as count 
      from 
        (select 
              concat(pconfig_id, "-", modname_id),
              modname_id,
              pconfig_id,
              count(*) as count
         from pmodules pm
          join pconfigs  pc on pc.id = pm.pconfig_id
         where
          pc.current = 1
          #{ptype}
         group by 1
        ) as r 
        join modnames  mn on mn.id = r.modname_id

      group by
        1
      }
    
    print sql
    
    #
    # returns frequency distribution of modules
    # as a hash
    
    mod_count = {}
    Pconfig.connection.select_all(sql).each do |row|
      row['count'] = row['count'].to_i
      row['modname_id'] &&= row['modname_id'].to_i
       
      #
      PconfigFlat.sum_row(ret,row, mod_count)
    end
        
    return ret
  end
  
  
  def self.get_key_frequency(type = nil, extra = "")
    ret = {:sum => 0,  :count => 0, :max => 0, :max_mcount => 0 }
    
    #
    # Returns a table that looks like this
    #
    # (ret[mod_name_id][pkey_id] = count, total_keys) 
    
    if(type == nil)
      ptype = "and type is null"  
    else
      ptype = "and type = '%s'" % (type)
    end
    
    #
    # get the count of each item
    #
    sum = 0 
    sql = %{
          /* key frequency */
          select
                concat(pconfig_id, "-", modname_id, '-', ifnull(pkey_id, '') ),
                count(*) as count,
                pkey_id,
                modname_id,
                site_id
          FROM 
                #{@@view_name}
          WHERE
                current = 1
                #{ptype}
                #{extra}
          group by 1
          /*order by 1 DESC*/
          }
    print sql
    
    mod_count = {}      
    Pconfig.connection.select_all(sql).each do |row|
        
      row['modname_id'] &&= row['modname_id'].to_i
      row['count']      &&= row['count'].to_i
      row['pkey_id']    &&= row['pkey_id'].to_i
      
      PconfigFlat.sum_row(ret,row, mod_count)
    end


    return ret
  end
  
  
  #
  #
  #
  def self.get_key_val_frequency(type = nil, extra = "")
    ret = {:sum => 0,  :count => 0, :max => 0, :max_mcount => 0 }
    
    #
    # get the frequency for each key_val, combination.
    #
    
    if(type == nil)
      ptype = "and type is null"  
    else
      ptype = "and type = '%s'" % (type)
    end
    
    #
    # get the count of each item
    #
    sum = 0 
    sql = %{
          /* key val frequency */      
    
            select
                  concat(pconfig_id, "-", modname_id, '-', ifnull(pkey_id, ''), '-', ifnull(pvalue_id, ''), '-', ifnull(pvalue_master_id, '') ),
                  count(*) as count,
                  pkey_id,
                  modname_id,
                  pvalue_id,
                  pvalue_master_id,
                  site_id
            FROM 
                  #{@@view_name}
            WHERE
                  current = 1
                  #{ptype}
                  #{extra}
            group by 1
            /*order by 1 DESC*/
        
    }
    print sql
    mod_count = {}
    Pconfig.connection.select_all(sql).each do |row|
      row['pvalue_master_id'] &&= row['pvalue_master_id'].to_i
      row['count']            &&= row['count'].to_i
      row['modname_id']       &&= row['modname_id'].to_i
      row['pkey_id']          &&= row['pkey_id'].to_i
      row['pvalue_id']        &&= row['pvalue_id'].to_i

      PconfigFlat.sum_row(ret,row, mod_count)
    end # end loop


    return ret
  end


  def self.sum_row(ret, row, mod_count)
    
    ret[:sum] += row['count']

    #
    # setup parts
    #
    
    if(! ret[row['modname_id'] ])
      ret[:count] += 1
      ret[row['modname_id'] ] = {:sum => 0, :count => 0, :max => 0, :mcount =>0 }
    end
    
    if(row['pkey_id'] && ! ret[row['modname_id'] ][ row['pkey_id']  ])
      ret[row['modname_id'] ][:count] += 1
      ret[row['modname_id'] ][ row['pkey_id']  ] = {:sum => 0,  :count => 0, :max => 0 }
    end
    
    if (row['pvalue_id'] && ! ret[row['modname_id'] ][ row['pkey_id']  ][row['pvalue_id'] ]  )
      ret[row['modname_id'] ][ row['pkey_id']  ][:count ] += 1
      ret[row['modname_id'] ][ row['pkey_id']  ][row['pvalue_id'] ] = {:sum => 0,  :count => 0, :max => 0 }
    end
    
    if(row['pvalue_master_id'] &&  ! ret[row['modname_id'] ][ row['pkey_id']  ][row['pvalue_id'] ][ row['pvalue_master_id'] ] )
      ret[row['modname_id'] ][ row['pkey_id']  ][row['pvalue_id'] ][ :count] += 1
      ret[row['modname_id'] ][ row['pkey_id']  ][row['pvalue_id'] ][ row['pvalue_master_id'] ]  = { :sum => row['count'],  :count => 0 , :max => 0 }            
    end
    
    #
    # Addition parts
    #
    
    if(row['pvalue_id'])
      ret[row['modname_id'] ][ row['pkey_id'] ][ row['pvalue_id'] ][:sum] += row['count']
      
      
      if( ret[row['modname_id'] ][ row['pkey_id'] ][:max] < ret[row['modname_id'] ][ row['pkey_id'] ][ row['pvalue_id'] ][:sum] )
        ret[row['modname_id'] ][ row['pkey_id'] ][:max]   = ret[row['modname_id'] ][ row['pkey_id'] ][ row['pvalue_id'] ][:sum]
      end    
    
    
      if( ret[row['modname_id'] ][ row['pkey_id'] ][ row['pvalue_id'] ][:max] < row['count'] )
        ret[row['modname_id'] ][ row['pkey_id'] ][ row['pvalue_id'] ][:max]   = row['count']
      end
      
    end
    
    
    if( row['pkey_id'])
      ret[row['modname_id'] ][ row['pkey_id'] ][:sum ] += row['count']
    
      if( ret[row['modname_id'] ][:max] < ret[row['modname_id'] ][ row['pkey_id'] ][:sum] )
        ret[row['modname_id'] ][:max]   =  ret[row['modname_id'] ][ row['pkey_id'] ][:sum]
      end

    end

    # modname stuff
    ret[row['modname_id'] ][:sum] += row['count']
    
    if( ret[:max] < ret[row['modname_id'] ][:sum] )
      ret[:max]   =  ret[row['modname_id'] ][:sum]
    end

    # special modcount stuff
    key = (row['site_id'].to_s + "|" + row['modname_id'].to_s)
    #p key
    if(row['site_id'] && ! mod_count[key])
      mod_count[key] = 1
      ret[row['modname_id'] ][:mcount] += 1
      
      if(ret[row['modname_id'] ][:mcount] > ret[:max_mcount])
        ret[:max_mcount] = ret[row['modname_id'] ][:mcount]
      end
    elsif(! row['site_id'])
      ret[row['modname_id'] ][:mcount] = row['count']
      
      if(ret[row['modname_id'] ][:mcount] > ret[:max_mcount])
        ret[:max_mcount] = ret[row['modname_id'] ][:mcount]
      end      
    
    end

  end # end this sum function


  #
  # Given one of my funky arrays of distribution information.
  # calculate some summary statistics for the distribution.
  #
  
  def self.calcute_distribution( ret )
    #
    # Takes my funky hash, and does the calculations necessary for it.
    #
    # I need to make more calculation here.
    #
    #  one.. sum excluding nil. ?
    #
    # need to incorporate a count variable
    
    # get scount
    scount = Pmodule.count_by_sql("select count(*) from pmodules group by modname_id  order by 1 DESC  limit 1")
    
  
    ret.keys.each do |a|                #mod
      next if (a.class == Symbol)
      ret[a].keys.each do |b|           # key
        next if (b.class == Symbol )
        ret[a][b].keys.each do |c|      # value
          next if (c.class == Symbol)
          ret[a][b][c].keys.each do |d|      # master value
            next if (d.class == Symbol)
            ret[a][b][c][d][:percent_overall] = ret[a][b][c][d][:sum] / ret[:sum].to_f
            ret[a][b][c][d][:percent_key]     = ret[a][b][c][d][:sum] / ret[a][b][:sum].to_f
            ret[a][b][c][d][:percent_mod]     = ret[a][b][c][d][:sum] / ret[a][:sum].to_f
            ret[a][b][c][d][:freq_val]        = ret[a][b][c][d][:sum] / ret[a][b][c][:max]    
          end     
          
          ret[a][b][c][:percent_overall] = ret[a][b][c][:sum] / ret[:sum].to_f
          ret[a][b][c][:percent_key]     = ret[a][b][c][:sum] / ret[a][b][:sum].to_f
          # of all the values for this key
          # what percentage were this value
          
          ret[a][b][c][:percent_mod]     = ret[a][b][c][:sum] / ret[a][:sum].to_f
          
          #ret[a][b][c][:freq_key]        = ret[a][b][c][:sum] / ret[a][b][:count].to_f  # how many relative to the number of items?            

          ret[a][b][c][:freq_key]        = ret[a][b][c][:sum] / ret[a][b][:max].to_f  # how many relative to the number of items?            
        end
        # key level
        ret[a][b][:percent_overall]   = ret[a][b][:sum] / ret[:sum].to_f
        ret[a][b][:percent_mod]       = ret[a][b][:sum] / ret[a][:sum].to_f

        ret[a][b][:freq_mod]        = ret[a][b][:sum] / ret[a][:max].to_f  # how many relative to the number of items?            
                                      # number of time this key occurs / total number of times any key in that module occurs.
        
      end
      # mod level
      ret[a][:freq_overall]      = ret[a][:count] / ret[:count].to_f  # how many relative to the number of items?            

      ret[a][:percent_mcount]   = ret[a][:mcount] / ret[:max_mcount].to_f                                   
      ret[a][:percent_overall]   = ret[a][:sum] / ret[:sum].to_f
      # number of times module occurs / number of times it could occur
      # 
      
    end
    
  end # end function


  #
  #
  # Co_occuring module names
  #
  #
  #return PconfigFlat.cooccuring_module_names(self, cutoff, limit, percent)
  def self.cooccuring_module_names(mod = None, cutoff = 1, limit = 20, type=nil)
    #freq = FreqMan.get_mod_frequency()
    
    # 
    # returns modules that Co-Occur.
    if(type == nil)
      ptype = "and type is null"  
    else
      ptype = "and type = '%s'" % (type)
    end
    
    
    ret = []
    count =1

    sql = %{
      select 
      	count(*) as count,
      	modname_id,
      	mn.modname
      from
        (
        select distinct(pm.pconfig_id) 
        
        from 
          pmodules pm
          join pconfigs pc on pc.id = pm.pconfig_id
          
        where 
          pm.modname_id=#{mod.modname_id} and
          pc.current =1
          #{ptype}
        ) as r
        join pmodules pm on pm.pconfig_id = r.pconfig_id
        join modnames mn on mn.id = pm.modname_id
         
      group by  modname_id
      order by 1 desc;
    }
    print sql
    
    Pmodule.connection.select_all(sql).each do |row|
        
        if( FreqMan.get_mod( row['modname_id'].to_i )[:percent_mcount] < cutoff )
          row['count'] = row['count'].to_i / mod.get_freq[:mcount].to_f                  
          ret << [ 
                   row['modname'],
                   row['modname_id'],
                   row['count'] ,
                   FreqMan.get_mod( row['modname_id'].to_i )[:percent_mcount]  
                 ] 
          #p ret.last
        end        
    end
    
    return ret[0..limit]
  end
  
  
  #
  # Co_occuring key names
  #
  #
  def self.cooccuring_keys(pattr, cutoff = 1, limit = 20, type = nil)
    # 
    # returns modules that Co-Occur.
    ret = []
    max=0

    if(type == nil)
      ptype = "and type is null"  
    else
      ptype = "and type = '%s'" % (type)
    end

    sql = %{
          /* coocurring in general */
          select 
    	      concat( pm.modname_id, '-', ifnull(pa.pkey_id,'')),	
            count(*) as count, k.pkey, pa.pkey_id, pm.modname_id
          from

          (select 
            pm.pconfig_id 
          from 
            pattributes pa 
            join pmodules pm on pa.pmodule_id = pm.id
            join pconfigs  pc on pc.id = pm.pconfig_id             
          where 
            pa.pkey_id= #{pattr.pkey_id} and
            pm.modname_id = #{pattr.pmodule.modname_id} and
            pc.current = 1 
            #{ptype}
            group by 1
          ) as r
          
          join pmodules pm on pm.pconfig_id = r.pconfig_id
          join pattributes pa on pa.pmodule_id = pm.id
          join pkeys k on k.id = pa.pkey_id
          
          group by 1
          order by 2 desc
    }
    
    print sql
    
    Pmodule.connection.select_all(sql).each do |row|
      #p row['modname_id']
      #p row['pkey_id']
      #p "--------------------------------------------------"
      #p pattr.key_freq(pattr.pmodule.modname_id )
      #p "--------------------------------------------------"
      

      if( FreqMan.get_key( row['modname_id'].to_i , row['pkey_id'].to_i)[:freq_mod] < cutoff )
        # this is probably the wrong value
        #p row['count']
        #p pattr.key_freq(pattr.pmodule.modname_id)[:sum]
        p row["count"]
        p pattr.key_freq(pattr.pmodule.modname_id)[:sum]
        

        
        row['count'] = row['count'].to_i / pattr.key_freq(pattr.pmodule.modname_id)[:sum].to_f                  
        ret << [ 
                 row['pkey'],
                 row['pkey_id'],
                 row['modname_id'],
                 row['count'] ,
                 FreqMan.get_key( row['modname_id'].to_i , row['pkey_id'].to_i)[:freq_mod]  
               ] 
        p ret.last
      end 
             
    end # loop

    return ret[0..limit]
  end
  


  #
  # Co-Ocurring keys in the module
  #
  
  def self.cooccuring_mod_keys(pattr, cutoff = 1, limit = 20, type = nil)
    # 
    # returns modules that Co-Occur.
    ret = []
    max=0

    if(type == nil)
      ptype = "and type is null"  
    else
      ptype = "and type = '%s'" % (type)
    end

    sql = %{
          /* query for co_occurign in same module */
          select 
    	      concat( pm.modname_id, '-', ifnull(pa.pkey_id,'')),	
            count(*) as count, k.pkey, pa.pkey_id, pm.modname_id
          from

          (select 
            pm.pconfig_id
          from 
            pattributes pa 
            join pmodules pm on pa.pmodule_id = pm.id
            join pconfigs  pc on pc.id = pm.pconfig_id 
          where 
            pa.pkey_id= #{pattr.pkey_id} and
            pm.modname_id = #{pattr.pmodule.modname_id} and
            pc.current  = 1
            #{ptype}
            group by 1
          ) as r
          join pmodules pm on pm.pconfig_id = r.pconfig_id
          join pattributes pa on pa.pmodule_id = pm.id
          join pkeys k on k.id = pa.pkey_id
          
          where 
          pm.modname_id = #{pattr.pmodule.modname_id}
          
          group by 1
          order by 2 desc
    }
    
    print sql
    
    Pmodule.connection.select_all(sql).each do |row|
      #p row['modname_id']
      #p row['pkey_id']
      #p "--------------------------------------------------"
      #p pattr.key_freq(pattr.pmodule.modname_id )
      #p "--------------------------------------------------"
      

      if( FreqMan.get_key( row['modname_id'].to_i , row['pkey_id'].to_i)[:freq_mod] < cutoff )
        # this is probably the wrong value

        row['count'] = row['count'].to_i / pattr.key_freq(pattr.pmodule.modname_id)[:sum].to_f                    
        ret << [ 
                 row['pkey'],
                 row['pkey_id'],
                 row['modname_id'],
                 row['count'] ,
                 FreqMan.get_key( row['modname_id'].to_i , row['pkey_id'].to_i)[:freq_mod]  
               ] 
        p ret.last
      end 
             
    end # loop

    return ret[0..limit]
  end
  
  #
  # -----------------------------------------------------------------------------------------------------------
  #
  
  #
  # Now it's time for some co-occurance on Values
  #
  #
  def self.cooccuring_key_val(pattr,cutoff = 1, limit = 20, type = nil)
    
    if(type == nil)
      ptype = "and type is null"  
    else
      ptype = "and type = '%s'" % (type)
    end
    
    # count(*) as count, concat(ifnull(pa.pkey_id,''),'|',ifnull(pa.pvalue_id,''),'|',ifnull(pa.pvalue_master_id,'') ) as cc
    # returns modules that Co-Occur.
    ret = []
    max=0
    
    sql = %{
      select 
      	count(*) as count, concat(pm.modname_id, '|',ifnull(pa.pkey_id,''),'|',ifnull(pa.pvalue_id,''),'|',ifnull(pa.pvalue_master_id,'') ) as cc,
      	k.pkey,
      	v.pvalue,
      	pa.pvalue_id,
      	pa.pkey_id,
      	pm.modname_id,
      	v2.pvalue as master_value
      from

      (select 
        pm.pconfig_id
      from 
        pattributes pa 
        join pmodules pm on pa.pmodule_id = pm.id
        join pconfigs  pc on pc.id = pm.pconfig_id   
      where 
        pa.pkey_id= #{pattr.pkey_id} and
        pa.pvalue_id= #{pattr.pvalue_id} and
        pm.modname_id = #{pattr.pmodule.modname_id} and
        pc.current = 1
        #{ptype}
        group by 1
      ) as r
      
      join pmodules pm on r.pconfig_id = pm.pconfig_id
      join pattributes pa on pa.pmodule_id = pm.id
      join pkeys k on k.id = pa.pkey_id
      join pvalues v on v.id = pa.pvalue_id
      
      left join pvalues v2 on v2.id = pa.pvalue_master_id

      group by 2
      order by 1 desc

    }
    print sql
    
     Pmodule.connection.select_all(sql).each do |row|
        row['modname_id'] &&= row['modname_id'].to_i
        row['pkey_id']    &&= row['pkey_id'].to_i
        row['pvalue_id']   &&= row['pvalue_id'].to_i

        p FreqMan.get_key_val( row['modname_id'] , row['pkey_id'], row['pvalue_id'])

        if( FreqMan.get_key_val( row['modname_id'] , row['pkey_id'], row['pvalue_id'])[:percent_key] < cutoff )
          # this is probably the wrong value

          row['count'] = row['count'].to_i / pattr.val_freq(pattr.pmodule.modname_id)[:sum].to_f                    
          ret << [ 
                   row['pkey'],
                   row['pvalue'],       
                   row['modname_id'],
                   row['pkey_id'],
                   row['pvalue_id'],                 
                   row['count'] ,
                   FreqMan.get_key_val( row['modname_id'] , row['pkey_id'], row['pvalue_id'])[:percent_key]  
                 ] 

          p ret.last
        end

      end

    return ret[0..limit]
  end


  
  def self.cooccuring_key_val_mod(pattr = None, cutoff = 1, limit = 20, type = nil)
    # 
    # returns modules that Co-Occur.
    
    if(type == nil)
      ptype = "and type is null"  
    else
      ptype = "and type = '%s'" % (type)
    end
    
    ret = []
    max=0
    sql = %{
      select 
          count(*) as count, concat(pm.modname_id, '|', ifnull(pa.pkey_id,''),'|',ifnull(pa.pvalue_id,''),'|',ifnull(pa.pvalue_master_id,'') ) as cc,
          k.pkey,
          v.pvalue,
          pa.pvalue_id,
          pa.pkey_id,
          pm.modname_id,
          v2.pvalue as master_value
      from

      (select 
        pm.pconfig_id
      from 
        pattributes pa 
        join pmodules pm on pa.pmodule_id = pm.id
        join pconfigs  pc on pc.id = pm.pconfig_id   
      where 
        pa.pkey_id= #{pattr.pkey_id} and
        pa.pvalue_id= #{pattr.pvalue_id} and
        pm.modname_id = #{pattr.pmodule.modname_id} and
        pc.current = 1  
        #{ptype}
        group by 1
      
      ) as r

      join pmodules pm on r.pconfig_id = pm.pconfig_id
      join pattributes pa on pa.pmodule_id = pm.id
      join pkeys k on k.id = pa.pkey_id
      join pvalues v on v.id = pa.pvalue_id
      
      left join pvalues v2 on v2.id = pa.pvalue_master_id

      where 
            pm.modname_id = #{pattr.pmodule.modname_id}

      group by 2
      order by 1 asc
    }
    
    print sql
    
    Pmodule.connection.select_all(sql).each do |row|
       row['modname_id'] &&= row['modname_id'].to_i
       row['pkey_id']    &&= row['pkey_id'].to_i
       row['pvalue_id']   &&= row['pvalue_id'].to_i

       p FreqMan.get_key_val( row['modname_id'] , row['pkey_id'], row['pvalue_id'])

       if( FreqMan.get_key_val( row['modname_id'] , row['pkey_id'], row['pvalue_id'])[:percent_key] < cutoff )
         # this is probably the wrong value

         row['count'] = row['count'].to_i / pattr.val_freq(pattr.pmodule.modname_id)[:sum].to_f                    
         ret << [ 
                  row['pkey'],
                  row['pvalue'],       
                  row['modname_id'],
                  row['pkey_id'],
                  row['pvalue_id'],                 
                  row['count'] ,
                  FreqMan.get_key_val( row['modname_id'] , row['pkey_id'], row['pvalue_id'])[:percent_key]  
                ] 

         p ret.last
       end

     end

    return ret[0..limit]
  end
  
  
  
end
class Pkey < ActiveRecord::Base
  has_many :pattributes
  
  
  # can't actually have these co-occuring things here
  # since we don't know the module.
  
  def cooccuring_keys(freq = None, cutoff = 1, limit = 20, percent = true)
    # 
    # returns modules that Co-Occur.
    ret = []
    max=0

    
    Pmodule.connection.select_all(%{
      select 
      	count(*) as count, k.pkey, pa.pkey_id, pm.modname_id
      from

      (select 	
      	pm.phpinfo_id 
      from 
      	pmodules pm 
      	join pattributes pa on pa.pmodule_id = pm.id
      where 
      	pa.pkey_id= #{self.id}
        group by 1
      ) as r

      join pmodules pm on r.phpinfo_id = pm.phpinfo_id
      join pattributes pa on pa.pmodule_id = pm.id
      join pkeys k on k.id = pa.pkey_id
      
      where pm.phpinfo_id = r.phpinfo_id

      group by 3
      order by 1 desc
      
    }).each do |row|

      #p freq[ row['modname_id'] ][row['pkey']]
      
      if(freq)
        ret << [ row['pkey'], row['pkey_id'], row['count'].to_i, row['modname_id'] ] if( freq[ row['modname_id'] ][row['pkey']] < cutoff )        
      else
        ret << [ row['pkey'], row['pkey_id'], row['count'].to_i, row['modname_id'] ]
      end
      max = max > row['count'].to_i ? max : row['count'].to_i
    end
    
    if(percent )
      #count = Pmodule.count_by_sql("select count(*) from pattributes where pkey_id=#{self.id}").to_f
      
      ret.each do |r|
        r[2] /= max.to_f #count
      end
    end
    
    return ret[0..limit]
  end
  
  
  def cooccuring_keys_in_mod(freq = None, cutoff = 1, limit = 20, percent = true)
    # 
    # returns modules that Co-Occur.
    ret = []
    max=0

    
    Pmodule.connection.select_all(%{
      select 
      	count(*) as count, k.pkey, pa.pkey_id, pm.modname_id
      from

      (select 	
      	pm.modname_id, pm.phpinfo_id
      from 
      	pmodules pm 
      	join pattributes pa on pa.pmodule_id = pm.id
      where 
      	pa.pkey_id= #{self.id.to_s}
      ) as r

      join pmodules pm on r.modname_id = pm.modname_id
      join pattributes pa on pa.pmodule_id = pm.id
      join pkeys k on k.id = pa.pkey_id
      
      where pm.phpinfo_id = r.phpinfo_id
      
      group by 3
      order by 1 desc

    }).each do |row|

      #p freq[ row['modname_id'] ][row['pkey']]
      
      if(freq)
        ret << [ row['pkey'], row['pkey_id'], row['count'].to_i, row['modname_id'] ] if( freq[ row['modname_id'] ][row['pkey']] < cutoff )        
      else
        ret << [ row['pkey'], row['pkey_id'], row['count'].to_i, row['modname_id'] ]
      end
      max = max > row['count'].to_i ? max : row['count'].to_i
    end
    
    if(percent )
      #count = Pmodule.count_by_sql("select count(*) from pattributes pa join pmodules p on pa.pmodule_id = p.id where pkey_id=#{self.id} and ").to_f
      ret.each do |r|
        r[2] /= max.to_f
      end
    end
    
    return ret[0..limit]
  end
  
end

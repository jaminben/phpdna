"""
  outputs vertexes in the format Eytan recommended.
  

"""
import MySQLdb
import time
import array
import matrix
import shelve

import igraph
import sys

from igraph import Graph

shf = shelve.open("big_list_db.bdb")

# restore this
relations    = shf['relations'] 
site_modules = shf['site_modules'] 

_big_list = matrix.Matrix(1,1)
_big_list.matrix = shf['big_list'] 
_big_list.rows   = len ( _big_list.matrix)
_big_list.cols   = len ( _big_list.matrix)

print len(_big_list.matrix)


"""
  Alright we have this matrix, now what do we want to do with it.

  -- well let's find the items with over X matches

"""

def prin(str1):
  sys.stderr.write(str(str1) + "\n")

gr = Graph()

gr.add_vertices( len(_big_list.matrix) )
# find out which ones are the most in 
MIN = 1 
for r,i,j in _big_list:
  if(_big_list.matrix[i][j] > MIN):
    prin( "%i ,%i = %i" %( i, j, _big_list.matrix[i][j]) )
    #prin( "Modules in 1:"   )
    #prin( site_modules[i]   )
    #prin( "Modules in 2:"   )
    #prin( site_modules[j]  )
    s2 = set(site_modules[i])
    s3 = set(site_modules[j])
    prin( len(s2 & s3 ) )
    prin( len(s2 | s3 ) ) 
#    prin("Stuff in common: ")
#    prin( s2 & s3 )
    
    
    print str(i) + " " + str(j) + " " + str(float(len(s2 & s3 ))/len(s2 | s3 )) 
    
    #gr.es
    #gr.add_edges( (i,j) )


#
#  - This will give me a basic idea of what's going on.
#  
# really what I am trying to do is identify features that create clusters?
#



# ok,
# and now to write it out:


#
# Now we need to 
#
# this will give us an IDEA of what is similar to each other?
#
# and can use iGraph to draw edges between these pieces? 


"""
dbh = MySQLdb.connect(host='localhost', db='php_info', user='php_info', passwd='c00l' )

c = dbh.cursor()

_start = time.time()
relations = {}
site_modules = {}

res = c.execute("select max(id) from sites")
(id,) = c.fetchone()
print id 

#build big table:
_big_list = matrix.Matrix(id+1,id+1)

res = c.execute("select  `key`, val, cmodule_id, site_id from cattributes ")
for (key,val, cmodule_id, site_id ) in c:
  if(not relations.get(key + "^" + val,False)):
    relations[key + "^" + val] = set() 
  if(not site_modules.get(site_id, False)):
    site_modules[site_id] = set()

  relations[key + "^" + val].add(site_id)
  site_modules[site_id].add(key + "^" + val)

c.close()

_similar = {}

cc = dbh.cursor()
# now add a ton of edges:
for k,v in relations.items():
  print k, len(v)
  c = 0
  for i in v:
    for j in v:
      if(i != j):
        _big_list.matrix[i][j] +=1
      c +=1
      # insert into the
#      (key,val) = k.split("^")
#      cc.execute("insert delayed into cattribute_edges (ky, val, in_site_id, out_site_id) values (%s, %s, %s , %s)", [key, val, i, j])
#    if( len(v) > 4 and c % int(len(v)*len(v) /4) == 0 ):
#      dbh.commit() 
#      print str( len(v) * len(v) - c) 

shf['relations'] = relations

shf['site_modules'] = site_modules

shf['big_list'] = _big_list.matrix

shf.close()
print "Saved"


#for r,i,j in _big_list:
#    print "%i ,%i = %i" %( i, j, _big_list.matrix[i][j])

#c = dbh.cursor()
#for r,i,j in _big_list:
#    if(not site_modules.get(i, None) or not site_modules.get(j, None)):
#      continue
#    print "%i, %i = %i -- %i -- %i " %( i, j, _big_list.matrix[i][j], len(site_modules[i]), len(site_modules[j]) )
#    c.execute("insert delayed into cattribute_sedges (in_site_id, out_site_id, common, in_site_mcount, out_site_mcount) values(%s, %s, %s, %s, %s )", (int(i), int(j), int(_big_list.matrix[i][j]), len(site_modules[i]), len(site_modules[j]) ))

#dbh.commit()

#print "Finished in: %s" %( time.time() -  _start)

"""
# comment all that out so we can remember what goes into it.


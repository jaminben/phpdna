import MySQLdb
import time
import array
import matrix
import shelve

shf = shelve.open("big_list_db.bdb")

"""
The idea is that this matrix can be used to do analysis


"""
dbh = MySQLdb.connect(host='localhost', db='php_info', user='root' )
#dbh = MySQLdb.connect(host='localhost', db='php_info', user='php_info', passwd='c00l' )
#dbh = MySQLdb.connect(host='localhost', db='php_info', user='php_info', passwd='c00l' )

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

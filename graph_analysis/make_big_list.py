import MySQLdb
import time
import array
import matrix
import sys

dbh = MySQLdb.connect(host='localhost', db='php_info', user='root' )

c = dbh.cursor()

_start = time.time()
relations = {}
site_modules = {}

res = c.execute("select max(id) from sites")
(id,) = c.fetchone()
print id 

#build big table:
_big_list = matrix.Matrix(id+1,id+1)

res = c.execute("select id, name, site_id from cmodules")
for (idd,name,site_id) in c:
  site_id = int(site_id)
  if(not relations.get(name,False)):
    relations[name] = set() 
  if(not site_modules.get(site_id, False)):
    site_modules[site_id] = set()

  site_modules[site_id].add(name)
  relations[name].add(site_id)

c.close()

_similar = {}

# now add a ton of edges:
for k,v in relations.items():
  print k, len(v)
  c = 0
  for i in v:
    for j in v:
      #if(i != j):
      key = "%s.%s" %(i,j)
      _big_list.matrix[i][j] +=1
      c +=1
    if( len(v) > 4 and c % int(len(v)*len(v) /4) == 0 ):
      sys.stdout.write(".")
      sys.stdout.flush()
      #print str( len(v) * len(v) - c) 


#for r,i,j in _big_list:
#    print "%i ,%i = %i" %( i, j, _big_list.matrix[i][j])

"""
jaccard2    -> ;+-----------------+---------------+------+-----+---------+-------+| Field           | Type          | Null | Key | Default | Extra |+-----------------+---------------+------+-----+---------+-------+| in_site_id      | int(11)       | YES  |     | NULL    |       | | out_site_id     | int(11)       | YES  |     | NULL    |       | | common          | int(11)       | YES  |     | NULL    |       | | jaccard         | decimal(18,8) | YES  |     | NULL    |       | | jaccard_common  | decimal(14,4) | YES  |     | NULL    |       | | in_site_mcount  | int(11)       | YES  |     | NULL    |       | | out_site_mcount | int(11)       | YES  |     | NULL    |       | +-----------------+---------------+------+-----+---------+-------+7 rows in set (0.09 sec)
"""

c = dbh.cursor()
for r,i,j in _big_list:
  print "%i, %i = %i" %( i, j, _big_list.matrix[i][j])
  if(_big_list.matrix[i][j] > 0):
    c.execute("insert into jaccard2 (in_site_id, out_site_id, common, in_site_mcount, out_site_mcount ) values(%s, %s, %s, %s, %s)", (int(i), int(j), int(_big_list.matrix[i][j]), len(site_modules[i]), len(site_modules[j])  ))
    dbh.commit()


print "Finished in: %s" %( time.time() -  _start)


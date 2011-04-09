import MySQLdb
import time
import array
import matrix

dbh = MySQLdb.connect(host='localhost', db='php_info', user='root' )

c = dbh.cursor()

_start = time.time()
relations = {}

res = c.execute("select max(id) from sites")
(id,) = c.fetchone()
print id 

#build big table:
_big_list = matrix.Matrix(id+1,id+1)

res = c.execute("select name, site_id from cmodules")
for (name,site_id) in c:
  if(not relations.get(name,False)):
    relations[name] = []
  relations[name].append(site_id)

c.close()

_similar = {}

# now add a ton of edges:
for k,v in relations.items():
  print k, len(v)
  c = 0
  for i in v:
    for j in v:
      if(i != j):
        key = "%s.%s" %(i,j)
        _big_list.matrix[i][j] +=1
      c +=1
    if( len(v) > 4 and c % int(len(v)*len(v) /4) == 0 ):
      print str( len(v) * len(v) - c) 


#for r,i,j in _big_list:
#    print "%i ,%i = %i" %( i, j, _big_list.matrix[i][j])

c = dbh.cursor()
for r,i,j in _big_list:
    print "%i, %i = %i" %( i, j, _big_list.matrix[i][j])
    c.execute("insert into sedges (in_site_id, out_site_id, common) values(%s, %s, %s)", (int(i), int(j), int(_big_list.matrix[i][j]) ))

dbh.commit()

print "Finished in: %s" %( time.time() -  _start)

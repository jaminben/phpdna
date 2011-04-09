import MySQLdb
import time

dbh = MySQLdb.connect(host='localhost', db='php_info', user='root' )

c = dbh.cursor()


_start = time.time()
relations = {}

res = c.execute("select max(id) from sites")
(id,) = c.fetchone()
print id 

#build big table:
_big_list = array()
for c in xrange(0, id+1):
  _big_list.append(array())
  for j in xrange(0, id+1):
    _big_list[c].append(0)

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
        if(not _similar.get(key, None)):
          _similar[key] = 0
        _similar[key] +=1
      c +=1
    if( c % int(len(v)*len(v) /4) == 0 ):
      print str( len(v) * len(v) - c) 

c = dhb.cursor()
for k,v in _similar:
      print k, v
      (item, in_item) = k.split(".")
      c.execute("insert into sedges (in_site_id, out_site_id, common) values(%s, %s, %i)", (item, in_item, v))

print "Finished in: %s" %( time.time() -  _start)

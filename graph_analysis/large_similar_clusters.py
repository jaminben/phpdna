import os 
import igraph
from igraph import Graph
import MySQLdb
import sys

dbh = MySQLdb.connect(host='localhost', db='php_info', user='root' )


INFILE      = "06attr"
OUTFILE_SVG = "attr_graph_06.svg"
OUTFILE_PNG = "attr_graph_06.png"

g = Graph.Load("06attr.net")
#g = Graph.Read_Ncol(INFILE)

#print g



#print g.is_directed()
#g.to_undirected(False)

#g = g.to_undirected()
#g = Graph.Load("output/SimpleModuleGraphALL.net")
#g = igraph.load("output/SimpleModuleGraph.net")

#print g.es
#print g.es["weight"]
#print g.cliques()
print g.is_directed()

print len(g.vs)
# delete edges that have low weight
to_del = []
#for e in g.es:
#  print e
#  if(e['weight'] < 0.6):
#    to_del.append(e.index)

    
#g.delete_edges(to_del)
g.simplify()

sub_g = g.subgraph(g.vs.select(_degree_gt=0)).decompose(minelements=2)

#del g

#print len(sub_g)
#c = 0
#for i in sub_g:
#  c +=1
#  if(c ==1):
#    base = i
#    continue
#  else:
#    print c
#    base = base.compose(i)
#    base.simplify()



def get_site(dbh, site):
  c = dbh.cursor()
  res = c.execute("select id, url from sites where id= %s", site)
  
  if(not res):
    return None
  (id, url) = c.fetchone()

  # get attributes
  #print "select `key`,val from cattributes where site_id = %s" % site

  c.execute("select `key`,val from cattributes where site_id = %s", site)
  keyvals = set()
  q = {}
  while(1):
    row = c.fetchone()
    if row == None:
      break
    (key, val) = row
    kv = key + "^^" + val
    keyvals.add(key + "^^" + val)
    q[key] = val
 
  # get modules
  mods = set()
  c.execute("select name from cmodules where site_id = %s", site)
  q = {}
  while(1):
    row = c.fetchone()
    if row == None:
      break
    (name,) = row
    mods.add(name)

  # ok to return
  #print "KEYVALS ------------------------------------------------------------------------"

  #print keyvals

  return {'id': id, 'url' : url, 'mods' : mods, 'attr' : keyvals, 'kv' : q} 


def plist(l):
  for i in l:
    print i

def compare(dbh, site1, site2):
  """
    A small function to compare two sites
    
    I will definitely need to do more work on this.
  """
  s1 = get_site(dbh, site1)
  s2 = get_site(dbh, site2)  

  print s1
  print s2

def compare_group(dbh, sites):
  """
    Takes a list of sites, and compares them
  
    a & b & c == modules in common
    a & b & c == attributes in common
  """
  mods = None 
  attr = None
 
  d_mods = set()
  d_attr = set()
  for i in sites:
    q = get_site(dbh, i)
   
    #if(q and len(q['mods']) > 0 and len(q['attr']) > 0):
    if(q and len(q['mods']) > 0 ):
      if(mods != None):
        mods = mods & q['mods']
      else:
        mods = q['mods']
      if(attr != None):
        attr = attr & q['attr']
      else:
        attr = q['attr']
 
      # not in all of them. 
      d_mods = d_mods | (q['mods'] - mods)
      d_attr = d_attr | (q['attr'] - mods)
    
      #print attr
      #print mods
      #print "-_-_________________________"   
  return (mods, attr, d_mods, d_attr) 



c = dbh.cursor()



print "done composing"
for i in sub_g:
  print "------------------------\n\n"
  print len(i.vs)
  print "\n"
  if(len(i.vs) < 10):
    continue
  
  ids = [v['id'] for v in i.vs] 
  print ids
  
  (a1, m1, a2, m2) = compare_group(dbh, ids)  

  print "____________________________________________________________________"
  plist( a1)
  plist(m1)
  print "____________________________________________________________________"
  plist( a2)
  plist(m2)
  print "____________________________________________________________________"
  
  for v in i.vs:
    res = c.execute("select url from sites where id = %s", v['id'][1:])
    a = c.fetchone()

    if( a and a[0]):
      url = a[0]
      print v['id'][1:] + " --> " + url

c.close()





#l = g.layout(layout='kk')
#l = g1.layout(layout='fruchterman_reingold', weights='weight', maxdelta=10000, maxiter=100)
#l = g1.layout(layout='fruchterman_reingold', maxdelta=10000, maxiter=100)

#g1.write_svg(OUTFILE_SVG, l, width=2048, height = 2048, vertex_size=5, font_size=12, labels='id'   )
#os.system("rsvg-convert %s -o %s" %(OUTFILE_SVG, OUTFILE_PNG))
#3os.system("open %s" % (OUTFILE_PNG))


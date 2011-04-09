import os 
import igraph
from igraph import Graph
import MySQLdb

dbh = MySQLdb.connect(host='xor', db='php_info', user='root' )


INFILE      = "output/small_jacc_70.net" 
OUTFILE_SVG = "out_jax_smaller_100_large.svg"
OUTFILE_PNG = "large_fully_similar.png"

#g = Graph.Load("output/SimpleModuleGraphALL.net")
g = Graph.Load(INFILE)
#g = igraph.load("output/SimpleModuleGraph.net")

#print g.es
#print g.es["weight"]
#print g.cliques()

print len(g.vs)
# delete edges that have low weight
to_del = []
for e in g.es:
#  print e
  if(e['weight'] < 0.90):
    to_del.append(e.index)

    
g.delete_edges(to_del)
g.simplify()

sub_g = g.subgraph(g.vs.select(_degree_gt=0)).decompose(minelements=20)

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

c = dbh.cursor()



#print "done composing"
for i in sub_g:
  print "------------------------\n\n"
  print len(i.vs)
  print "\n"
  for v in i.vs:
    res = c.execute("select url from sites where id = %s", v['id'][1:])
    (url,) = c.fetchone()
    res = c.execute("select val from cattributes where site_id = %s and `key` = 'Configuration File (php.ini) Path'", v['id'][1:])
    (cpath,) = c.fetchone()
    res = c.execute("select val from cattributes where site_id = %s and `key` = 'Configure Command'", v['id'][1:])
    if(c.rowcount > 0 ):
      (ccommand,) = c.fetchone()
      print "command -->" + ccommand.replace("&#039;",";")
   
    res = c.execute("select val from cattributes where site_id = %s and `key` = 'Client API Version'", v['id'][1:])
    if(c.rowcount > 0 ):
      (apiv,) = c.fetchone()
      print "api -->" + apiv
    print v['id'][1:] #+ "--> " + url    
    print "config path -->" + cpath 
  g1 = i

c.close()

print len(g1.vs)
print len(g1.es)


print len(g1.es)

#l = g.layout(layout='kk')
#l = g1.layout(layout='fruchterman_reingold', weights='weight', maxdelta=10000, maxiter=100)
#l = g1.layout(layout='fruchterman_reingold', maxdelta=10000, maxiter=100)

#g1.write_svg(OUTFILE_SVG, l, width=2048, height = 2048, vertex_size=5, font_size=12, labels='id'   )
#os.system("rsvg-convert %s -o %s" %(OUTFILE_SVG, OUTFILE_PNG))
#3os.system("open %s" % (OUTFILE_PNG))


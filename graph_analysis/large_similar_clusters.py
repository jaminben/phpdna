import os 
import igraph
from igraph import Graph
import MySQLdb
import sys

dbh = MySQLdb.connect(host='localhost', db='php_info', user='root' )


INFILE      = "06attr"
OUTFILE_SVG = "attr_graph_06.svg"
OUTFILE_PNG = "attr_graph_06.png"

#g = Graph.Load("output/SimpleModuleGraphALL.net")
g = Graph.Read_Ncol(INFILE)

g.write("test.net", "pajek")

sys.exit(0)


print g.is_directed()
g.to_undirected(False)

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

c = dbh.cursor()



print "done composing"
for i in sub_g:
  print "------------------------\n\n"
  print len(i.vs)
  print "\n"
  for v in i.vs:
    print v
    print v.index
    #res = c.execute("select url from sites where id = %s", v['id'][1:])
    res = c.execute("select url from sites where id = %s", v.index)
    a = c.fetchone()
    if(a and a[0]):
      #print v['id'][1:] + " --> " + url
      print str(v.index) + " --> " + str(a[0])
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


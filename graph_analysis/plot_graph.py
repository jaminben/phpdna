import os 
import igraph
from igraph import Graph
print igraph



INFILE      = "attr_edges"
OUTFILE_SVG = "attr_graph_06.svg"
OUTFILE_PNG = "attr_graph_06.png"

#g = Graph.Load("output/SimpleModuleGraphALL.net")
g = Graph.Read_Ncol(INFILE)


#g = Graph.Load("output/SimpleModuleGraphALL.net")
#g = igraph.load("output/SimpleModuleGraph.net")

#print g.es
#print g.es["weight"]
#print g.cliques()

to_del = []
# delete edges that have low weight
for e in g.es:
#  print e
  if(e['weight'] < 0.60):
    to_del.append(e.index)


#simple test:
#print g.vs[1]
g = g.delete_edges(to_del)
#print g.vs[1]

#v =  g.vs[1]
#g.delete_vertices(v.index)
#print v
#print g.vs[1]

#exit()

#removed = []
#print len(g.vs)
g.simplify()
#for v in g.vs:
#  if g.degree(v) == 0:
    #g.delete_vertices(v.index)
#    if(v['id']):
#    removed.append(v.index)

#g.delete_vertices(removed)
    
  #elif g.degree(v) == 1:
    #print v
    #ed  = g.es[ g.adjacent(v.index)[0] ]
    #print g.vs[ed.source]
    #print g.vs[ed.target]
    #print "\n" 
#  elif(g.degree(v) == 1):
#    print g.degree(v)


#print g.decompose(minelements=2)

print len(g.vs)

g1 = g.subgraph(g.vs.select(_degree_gt=0))

print len(g1.vs)


#for i in g1.vs:
#  if( i['id'] in ded):
#    print "WTF"
#    print i

#l = g.layout(layout='kk')
l = g1.layout(layout='fruchterman_reingold', weights='weight', maxdelta=10000, maxiter=1000)
g1.write_svg(OUTFILE_SVG, l, width=2048, height = 2048, vertex_size=5, font_size=12, labels='id' )
os.system("rsvg-convert %s -o %s" %(OUTFILE_SVG, OUTFILE_PNG))
os.system("open %s" % (OUTFILE_PNG))


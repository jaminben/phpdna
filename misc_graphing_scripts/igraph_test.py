import os 
import igraph
from igraph import Graph
print igraph

INFILE      = "new_graph.net" 
OUTFILE_SVG = "new_graph.svg"
OUTFILE_PNG = "new_graph.png"

#g = Graph.Load("output/SimpleModuleGraphALL.net")
g = Graph.Load(INFILE)
#g = igraph.load("output/SimpleModuleGraph.net")

#print g.es
#print g.es["weight"]
#print g.cliques()

print len(g.vs)
# delete edges that have low weight
to_del = []
#for e in g.es:
#  print e
#  if(e['weight'] < 0):
#    to_del.append(e.index)

    
#g.delete_edges(to_del)
g.simplify()

g1 = g.subgraph(g.vs.select(_degree_gt=0))
print len(g1.vs)

#l = g.layout(layout='kk')
l = g1.layout(layout='fruchterman_reingold', weights='weight', maxdelta=10000, maxiter=100)

g1.write_svg(OUTFILE_SVG, l, width=2048, height = 2048, vertex_size=5, font_size=12 , labels='id')
os.system("rsvg-convert %s -o %s" %(OUTFILE_SVG, OUTFILE_PNG))
os.system("open %s" % (OUTFILE_PNG))


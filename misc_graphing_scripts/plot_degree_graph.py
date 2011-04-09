import os 
import igraph
from igraph import Graph
print igraph

INFILE      = "output/small_jacc_70.net" 
OUTFILE_SVG = "out_jax_smaller_70.svg"
OUTFILE_PNG = "out_jac_70.png"

#g = Graph.Load("output/SimpleModuleGraphALL.net")
g = Graph.Load(INFILE)
#g = igraph.load("output/SimpleModuleGraph.net")

#print g.es
#print g.es["weight"]

# delete edges that have low weight
for e in g.es:
#  print e
  if(e['weight'] < 0.80):
    g.delete_edges(e)


g.simplify()

for v in g.vs:
  if g.degree(v) == 0:
    g.delete_vertices(v)
#  elif(g.degree(v) == 1):
#    print g.degree(v)

#l = g.layout(layout='kk')
l = g.layout(layout='fruchterman_reingold', weights='weight', maxdelta=10000, maxiter=1000)

g.write_svg(OUTFILE_SVG, l, width=2048, height = 2048, vertex_size=5, font_size=12 )
os.system("rsvg-convert %s -o %s" %(OUTFILE_SVG, OUTFILE_PNG))
os.system("open %s" % (OUTFILE_PNG))


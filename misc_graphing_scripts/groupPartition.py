from etools import *
from igraph import *

weights = {}

def clean(s):
	return s.strip().replace('\"','').replace('\'','')

def loadGraph():
	l = [clean(line).split(',') for line in open("/Users/ebakshy/SL/data/ggfiltered.csv")]
	edges = [(gid1,gid2) for gid1,gid2,weight in l]

	uniqueNodes = list(set(flatten(edges)))

	idxNode = dict(enumerate(uniqueNodes))
	nodeIdx = reverseDict(idxNode)

	weights = dict([(tuple(sorted((nodeIdx[gid1],nodeIdx[gid2]))), float(weight)) for gid1,gid2,weight in l])

	g = Graph([(nodeIdx[gid2],nodeIdx[gid1]) for gid1,gid2 in edges])
	for i,v in enumerate(g.vs):
		v['id'] = idxNode[i]
	for e in g.es:
		e['weight'] = weights[tuple(sorted(e.tuple))]

	return g.simplify()

dendrogramList = []
t = {}
c = []
def dendrogram(g):
	gg = g.components().giant()
	c = gg.community_fastgreedy()
	plot(c)

	t = {}
	n = gg.vcount()
	for i,merge in enumerate(c.merges):
		t[i+n] = merge
	for i, merge in t.iteritems():
		t[i] = remapList(t,list(merge))
	dendrogramList = remapList(t,t[2 * (n - 1) ])	# last element of t is complete dendrogram list
	idxToGid = dict(enumerate(gg.vs.get_attribute_values('id')))
	return remapList(idxToGid,dendrogramList)

def filterGraph(g,w):
	esq = g.es.select(weight_ge = w)
	edges = [e.tuple for e in esq]
	uniqueNodes = list(set(flatten(edges)))
	idxNode = dict(enumerate(uniqueNodes))
	nodeIdx = reverseDict(idxNode)
	
	s = Graph([(nodeIdx[i],nodeIdx[j]) for i,j in edges])
	for attr in g.es.attribute_names():
		s.es.set_attribute_values(attr, [e[attr] for e in esq])
	for attr in g.vs.attribute_names():
		s.vs.set_attribute_values(attr, [g.vs[i][attr] for i in uniqueNodes])

	return s

def mathGraph(g):
	return [e.tuple for e in g.es]

#for e in g.es:
#	e['weight'] = weights[e.tuple]
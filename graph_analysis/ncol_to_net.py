#!/usr/bin/python

"""
  This is a very simple script that takes an Ncol format file
  and outputs that Ncol file as a .net FILE

"""

import sys

nodes =set() 

for i in open(sys.argv[1]):
  p = i.split(" ")
  if(len(p)>2):
    nodes.add(p[0])
    nodes.add( p[1])

# print out the nodes:
print "*Vertices %s" %(len(nodes))
j =0 
for i in nodes:
  j += 1
  print  """%s "n%s" 0.0 0.0 0.0""" % (j, j )

# now loop through 
print "*Arcs"
for i in open(sys.argv[1]):
  sys.stdout.write( i)  

#!/usr/bin/python

"""
  This is a very simple script that takes an Ncol format file
  and outputs that Ncol file as a .net FILE

"""

import sys

max = 0

for i in open(sys.argv[1]):
  p = i.split(" ")
  if(len(p)>2):
    if( int(p[0]) > max):
      max = int(p[0])
    if(int(p[1]) > max):
      max = int(p[1])
        
# print out the nodes:
print "*Vertices %s" %(max)
j =0 
for i in xrange(1,max):
  j += 1
  print  """%s "%s" 0.0 0.0 0.0""" % (j, j )

# now loop through 
print "*Edges"
for i in open(sys.argv[1]):
  sys.stdout.write( i)  

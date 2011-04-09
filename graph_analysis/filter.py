"""
  Reads a file
  splits in into 3 pieces
  convert's the 3rd piece to an int
  and then prints it out if greater than second variable
  prints stats to STDERR
"""
import sys

def prin(str2):
  sys.stderr.write(str( str2 )+ "\n")


r = open(sys.argv[1])

rr = float(sys.argv[2])

cnt = 0
tot = 0
for i in r:
  p = i.split(" ")
  if(float(p[2]) > rr):
    sys.stdout.write(i)

  tot += float(p[2])
  cnt += 1

prin(tot/cnt)
 
  


import MySQLdb
from MySQLdb.cursors import SSCursor # http://jjinux.blogspot.com/2007/01/python-dealing-with-huge-data-sets-in.html
import time
import sys

"""
  Takes a MySQL Query and builds a graph.. in ONE PASS.

"""

def no_map(node):
  return node

class FastGraph:
  def __init__(self, nodes_query, edges_query, dbh, node_map_func = None):
    
    self.dbh = dbh
    self.nodes_query = nodes_query
    self.edges_query  = edges_query
    self.node_map_func = node_map_func
  
    if(not self.node_map_func):
      self.node_map_func = self.map_node


  def map_node(self, node):
    return "n" + str(node)


  def write_net(self, filename):
    f= open(filename, "w")
    
    print "\nOpened %s for writing\n" %(filename)
    
    # write nodes
    self.write_nodes(f, self.net_node)

    #write edges
    self.write_edges(f, self.net_edge)

    print "\nFinished\n" 
    
    f.close()

  # this is how we write a node
  def net_node():
    pass
  def net_edge():
    pass


  def write_nodes(self, fh, node_func):
    # run the SQL query
    c = self.dbh.cursor()
    
    _start = time.time()

    c.execute(self.nodes_query)

    # write the header:
    fh.write("*Vertices\t%i\r\n" %(c.rowcount))

    self.map = {}

    count = 0
    for (_node, _x, _y, _z) in c:
      count +=1
      # could call external func here
      fh.write("%i \"%s\" %f %f %f\r\n" %(count, _node, _x, _y, _z))
      self.map[_node] = count
    
      if(count % 100 == 0):
        sys.stdout.write('.')        
        sys.stdout.flush()

    # end this function
    c.close()
    print "\nWrote %i Nodes in %f\n" %(count, time.time() - _start)
 
  def write_edges(self, fh, edge_func):
    c = SSCursor(self.dbh)
    _start = time.time()

    c.execute(self.edges_query)

    # write the header:
    fh.write("*Arcs\r\n")
    
    # I need some duplicate protection

    count = 0
    res = c.fetchone()
    while( res):
      (_to, _from, _weight) = res
      count +=1
      # could call external func here
      fh.write("%s %s %f\r\n" %(self.map[_to], self.map[_from], (_weight or 1)))
      if(count % 1000 == 0):
        sys.stdout.write('.')        
        sys.stdout.flush()
      
      # get next record
      res = c.fetchone()
      
    # end this function
    c.close()
    print "\nWrote %i Edges in %f\n" %(count, time.time() - _start)
      

dbh = MySQLdb.connect(host='localhost', db='php_info2', user='root' )

nodes_sql= """select id,0,0,0 from pconfigs """
edges_sql= """select in_id as `from`, out_id as `to`, mods_jaccard from compare_edges where mods_jaccard > 0.7"""

g = FastGraph(nodes_sql, edges_sql, dbh)

g.write_net("big_graph.net")


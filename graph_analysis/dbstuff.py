import sys
sys.path.append('.')
from bootstrap import *
import time
import os
import threading

import Pool

#
# I want to have multiple pools.
#
#

MAX_TRIES = 10

g_dbh_pool = {}
g_dbh = None
g_dbh_ro = {}

def filter_hash(hsh):
  ret = {}
  for i in ["host", "db", "user", "passwd"]:
    ret[i] = hsh[i]
  return ret
  
def getConnectInfo(key):
  #
  # This is just to be backwards compatible, with kevin's old stuff
  # so if it can get the key for the DB handle, and return it.. do that
  # otherwise, 
  if( DB.get(key, None)):
    return filter_hash(DB[key])
  else:
    return filter_hash(DB)

def real_getRW(key = "default" ):
  global g_dbh_pool
  if g_dbh_pool.get(key,None) is None:
    import MySQLdb
    g_dbh_pool[key] = Pool.Pool(Pool.Constructor(MySQLdb.connect,**getConnectInfo(key)), getConnectInfo(key).get("connections", 30) )
    
  return g_dbh_pool[key].get()

def getRW(key = "default"):
  ret = None
  c = 0
  while (ret is None and c < MAX_TRIES):
    ret = real_getRW(key)
    if(ret is None):
      c += 1
      time.sleep(0.05 * c * c)
  # return the value 
  return ret  
 
def release(dbh, key = "default"):
  global g_dbh_pool
  
  # make sure we have the handle
  if g_dbh_pool.get(key,None) is None:
    return False
  
  g_dbh_pool[key].put(dbh)
  
def getRO(key = "default"):
  return getRW(key)
  #global g_dbh_ro
  #if g_dbh_ro is None:
  #  g_dbh_ro = MySQLdb.connect()
  #return g_dbh_ro
# vi: sts=2 et sw=2

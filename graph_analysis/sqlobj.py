import dbstuff
import MySQLdb
import re
import threading

try:
  import cPickle
  pickle=cPickle
except:
  import pickle

DEBUG = False 
#DEBUG = True
#False 

class ObjectNotFound(Exception):
  def __init__(self, msg):
    Exception.__init__(self, msg)

schemas = {}

def makeListIfPossible(d):
  """Take a dictionary and turn it into a list (if that's reasonable)"""
  rv = []
  try:
    for k in d:
      i = int(k)
      if i<0:
        return d
      if i>=len(rv):
        rv += ((i+1)-len(rv))*[None]
      rv[i] = d[k]
  except ValueError:
    # non-numeric key? leave it as a dict
    return d
  return rv

class SQLObject(object):
  SQLTable = "horrible_error"
  SQLId = "id"

  def __init__(self, id=0, dbh=None, fields=[], dbh_key = "default"):
    object.__setattr__(self, "sqlfields", {})
    self.idfield = self.SQLId
    self.table = self.SQLTable
    self.sqlfields = schemas.get(self.table,{})
    self.dbh_key = dbh_key
    
    self.selected = False

    release = False
    if dbh is None:
      dbh = dbstuff.getRW(self.dbh_key)
      release = True

    try:
      if self.sqlfields=={}:
        query = "DESCRIBE " + self.table
        c = dbh.cursor()
        c.execute(query)
        for column,coltype,null,key,default,extra in c:
          self.sqlfields[column] = 1
          self.__setattr__("_sql_" + column, default)
        schemas[self.table] = self.sqlfields
  
      self.id = id
      if self.id:
        query = "SELECT "
        if len(fields)>0:
          query += ",".join(fields) + " "
        else:
          query += "* "
        query += "FROM " + self.table + " WHERE " + self.idfield + "=%s"
        
        if (DEBUG):
          print query
        
        c = dbh.cursor(MySQLdb.cursors.DictCursor)
        c.execute( query, id )
        self.selected = True
        # else object not found
        if c.rowcount>0:
          d = c.fetchone()
          for k,v in d.items():
            self.__setattr__("_sql_" + k, v)
          self.sqlfields[self.idfield] = 1
        else:
          raise ObjectNotFound( self.table + " " + str(id) )
      else:
        for k in self.sqlfields:
          self.sqlfields[k] = 2
    finally:
      if release:
        dbstuff.release(dbh, self.dbh_key)

  def __getattribute__(self, name):
    if name in object.__getattribute__(self, "sqlfields"):
      name = "_sql_" + name
    # temporary hack
    try:
      return object.__getattribute__(self, name)
    except AttributeError:
      if name=='_sql_extra':
        return pickle.dumps({})
      else:
        return None

  def __setattr__(self, name, value):
    """Update the database representation of this object if necessary."""
    if name==self.SQLId:
      object.__setattr__(self, 'id', value)
    if name in self.sqlfields:
      self.sqlfields[name] = 2
      #c = self.dbh.cursor()
      #query = "UPDATE " + self.table + " SET " + name + "=%s WHERE " + self.idfield + "=%s"
      #c.execute(query, (value, self.id))
      name = "_sql_" + name
      #self.dbh.commit()
    return object.__setattr__(self, name, value)


  #
  # In theory.. we could convert other fields into this HASH to.. like
  # a list of EXTRA attribs, that aren't written to SQL, but persisted.
  # perhaps that should be a memcache thing.
  def to_hash(self):
    hsh = {}  
    for k in self.sqlfields.keys():
      hsh[k] = self.__getattribute__("_sql_"+k)
    return [self.sqlfields, hsh]

  def from_hash(self, hsh, selected = True):
    self.sqlfields = hsh[0]
    self.selected  = selected 
    for k in self.sqlfields.keys():
      self.__setattr__(k, hsh[1][k])

 
  def save(self):
    dbh = dbstuff.getRW(self.dbh_key)
    try:
      c = dbh.cursor()
      cols,vals = [],[]
      for k,v in self.sqlfields.items():
        if v > 1 or k==self.idfield:
          try:
            vals.append(self.__getattribute__("_sql_"+k))
            cols.append('`' + k + '`')
          except AttributeError:
            # just skip missing attrs
            pass
      if not self.selected:
        query = "INSERT INTO " + self.table + " (" + ','.join(cols) + ") VALUES (" + ','.join(['%s' for v in vals]) + ")"
        if (DEBUG):
          print query
        c.execute(query, tuple(vals))
        dbh.commit()
        if not self.id:
          self.__setattr__(self.SQLId, c.lastrowid)
        self.selected = True
      else:
        if cols:
          query = "UPDATE " + self.table + " SET " + ','.join(["%s=%%s" % k for k in cols]) + " WHERE " + self.idfield + "=%s"
          if (DEBUG):
            print query
          c.execute(query, tuple(vals + [self.id]))
          dbh.commit()
      c.close()
    finally:
      dbstuff.release(dbh, self.dbh_key)

  def delete(self):
    """Remove the database representation of this object.

    You shouldn't attempt to mess with this object after calling delete();
    probably something bad will happen.
    """
    query = "DELETE FROM " + self.table + " WHERE " + self.idfield + "=%s"
    dbh = dbstuff.getRW(self.dbh_key)
    try:
      c = dbh.cursor()
      c.execute(query, self.id)
      c.close()
      dbh.commit()
    finally:
      dbstuff.release(dbh,self.dbh_key)

  def setFromDict(self, dct):
    def layers(s):
      stuff = s.split('[')
      rv = []
      for x in stuff:
        if x[-1]==']':
          x = '[' + x
        rv.append(x)
      return rv
    maxdepth = 0
    for k in dct:
      tmp = layers(k)
      if len(tmp)>maxdepth:
        maxdepth = len(tmp)
    for i in range(maxdepth,1,-1):
      dct1 = {}
      for k,v in dct.items():
        stuff = layers(k)
        if len(stuff)<i:
          dct1[k] = v
        else:
          k1 = ''.join(stuff[:-1])
          k2 = stuff[-1][1:-1]
          if k1 not in dct1:
            dct1[k1] = {}
          dct1[k1][k2] = v
      dct = {}
      for k,v in dct1.items():
        if type(v)==type({}):
          v = makeListIfPossible(v)
        dct[k] = v
      #setMessage(str(i) + '!! => ' + str(dct))

    for k,v in dct.items():
      mo = re.match(r'chkbox_(.+)_present', k)
      if mo:
        k1 = mo.group(1)
        if k1!=self.SQLId:
          self.__setattr__(k1, 0)
    for k,v in dct.items():
      if k!=self.SQLId:
        #setMessage("set %s => %s" % (str(k), str(v)))
        self.__setattr__(k, v)

def SQLFactory(cls, keys={}, sort=[], multi=False, dbh=None, dbh_key="default"):
  """Pull an instance of a class from the database."""
  rv = None
  if multi:
    rv = []
  release = False
  if dbh is None:
    release = True
    dbh = dbstuff.getRO(dbh_key)
  try:
    whereclause = []
    wherevalues = []
    for k,v in keys.items():
      if k[0]=='<':
        whereclause.append('%s<%%s' % k[1:])
      elif k[0]=='>':
        whereclause.append('%s>%%s' % k[1:])
      else:
        whereclause.append('%s=%%s' % k)
      wherevalues.append(v)
    query = "SELECT " + cls.SQLId + " FROM " + cls.SQLTable 
    if whereclause:
      query += " WHERE " + ' AND '.join(whereclause)
    if sort:
      if type(sort)!=type([]):
        sort = [sort]
      query += " ORDER BY " + ','.join([' `%s` %s' % (k,d) for k,d in sort])
    c = dbh.cursor()
    
    if (DEBUG):
      print query
    
    c.execute( query, tuple(wherevalues) )
    if c.rowcount>0:
      if multi:
        for id, in c:
          rv.append(cls(id,dbh))
      else:
        #print "ROW COUNT"
        #print c.rowcount
        (id,) = c.fetchone()
        rv = cls(id, dbh)
    c.close()
  finally:
    if release:
      dbstuff.release(dbh,dbh_key)
  return rv

def SQLNewFactory(cls, data, dbh=None, dbh_key = "default"):
  """Create a new instance of a class."""
  release = False
  if dbh is None:
    release = True
    dbh = dbstuff.getRW(dbh_key)
  try:
    columns = []
    values = []
    for k,v in data.items():
      columns.append('`' + k + '`')
      values.append(v)
    query = "INSERT INTO " + cls.SQLTable + " (" + ",".join(columns) + ") VALUES (" + ",".join(["%s" for v in values]) + ")"
    c = dbh.cursor()
    if (DEBUG):
      print query
    c.execute( query, tuple(values) )
    id = c.lastrowid
    c.close()
    dbh.commit()
  finally:
    if release:
      dbstuff.release(dbh,dbh_key)
  return cls(id, dbh)

# here are some handy descriptors

class notifydictwrapper(object):
  """Dictionary that adds a callback on setitem"""
  def __init__(self, d={}, call = None):
    self._data = d
    self.set_callback = call
  
  def __setitem__(self, key, value):
    if(self.set_callback):
      self.set_callback(key,value)
    self._data[key] = value
    return self._data[key]
 
  def __getitem__(self, key):
    return self._data.get(key,False)
  
  def _set(self, key, value):
    """ Set a value without an update """
    self._data[key] = value
    return self._data[key] 
  
  def get(self,key,default = None):
    return self._data.get(key,default)
    
  def __setitem__(self, k, v):
    self._data[k] = v
    if(self.set_callback):
      self.set_callback(k,v)
    return self._data[k]
 
  def to_dict(self):
    return self._data
    return dict(self._data)
  
class notifydict(dict):
  """Dictionary that adds a callback on setitem"""
  def __init__(self, f, a, d={}):
    self.f = f
    self.args = a
    dict.__init__(self, d)

  def __setitem__(self, k, v):
    dict.__setitem__(self, k, v)
    a1 = self.args + [dict(self)]
    self.f(*a1)

class pickledict(object):
  """Descriptor for updating a pickled dictionary"""
  def __init__(self, colname, default={}):
    self.colname = colname
    self.default = default

  def __get__(self, obj, objtype=None):
    v = obj.__getattribute__(self.colname)
    if v:
      v = pickle.loads(v)
    else:
      v = self.default
    return notifydict(self.__set__, [obj], v)

  def __set__(self, obj, val):
    obj.__setattr__(self.colname, pickle.dumps(dict(val)))

class foreign(object):
  """Reference a foreign key"""
  def __init__(self, cls, colname):
    self.cls = cls
    self.colname = colname
    self.v = None

  def __get__(self, obj, objtype=None):
    if self.v is None:
      self.v = cls(obj.__getattribute__(self.colname))
    return self.v

  def __set__(self, obj, val):
    obj.__setattr__(self.colname, val.id)

# vi: sts=2 et sw=2

from itertools import *

class Memoize:
    """Memoize(fn) - an instance which acts like fn but memoizes its arguments
       Will only work on functions with non-mutable arguments
    """
    def __init__(self, fn):
        self.fn = fn
        self.memo = {}
    def __call__(self, *args):
        if not self.memo.has_key(args):
            self.memo[args] = self.fn(*args)
        return self.memo[args]

class DefaultDict(dict):
    """Dictionary with a default value for unknown keys."""
    def __init__(self, default):
        self.default = default

    def __getitem__(self, key):
        if key in self: 
            return self.get(key)
        else:
            ## Need copy in case self.default is something like []
            return self.setdefault(key, copy.deepcopy(self.default))

    def __copy__(self):
        copy = DefaultDict(self.default)
        copy.update(self)
        return copy


def reverseDict(d):
    "Return a new dict with swapped keys and values"
    return dict(izip(d.itervalues(), d))

def flatten(listOfLists):
	return list(chain(*listOfLists))

def flattenAll(seq):
  "Completely flattens shit"
  lst = []
  for el in seq:
    if type(el) == list or type(el) is tuple:
      lst.extend(flattenAll(el))
    else:
      lst.append(el)
  return lst

def flattenAfter(seq,n):
	"""flattens all sequences into a list after n levels"""
	if isinstance(seq,list) or isinstance(seq,tuple):
		if n == 0:
			return flattenAll(seq)
		else:
			return [flattenAfter(i,n-1) for i in seq]
	else:
		return seq


def remapList(d,x):
	if(isinstance(x,list) or isinstance(x,tuple)):
		return [remapList(d,i) for i in x]
	elif(d.has_key(x)):
		return d[x]
	else:
		return x

def clean(s):
	return s.strip().replace('\"','').replace('\'','')

def unionize(x):
	return list(set(flattenAll(x)))
import array
#
class Matrix(object):
#
    def __init__(self, cols, rows):
        self.cols = cols
        self.rows = rows
        # initialize matrix and fill with zeroes
        self.matrix = []
        for i in range(rows):
            ea_row = array.array('l') 
            for j in range(cols):
                ea_row.append(0)
            self.matrix.append(ea_row)
#
    def setitem(self, col, row, v):
        self.matrix[col-1][row-1] = v
 
    def getitem(self, col, row):
        return self.matrix[col-1][row-1]
#
    def __repr__(self):
        outStr = ""
        for i in range(self.rows):
            outStr += 'Row %s = %s\n' % (i+1, self.matrix[i])
        return outStr

    def __iter__(self):
      for row in range(self.rows):
        for col in range(self.cols):
          yield (self.matrix, row, col) 

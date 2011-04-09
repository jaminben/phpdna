#
# Has to be run inside of the rails ENV
#
#
#
require 'phpinfo_parser'

contents = open("tmp/info.html").read

DEBUG = true
pp = PhpinfoParser.parse_string(contents)

#p pp.config


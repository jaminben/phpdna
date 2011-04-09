*Collecting Data*

_Easier than you'd think_

*collect.rb*

Basically I use the Yahoo Search API to search and download 
files that contain the phrase _"phpinfo()"_ and _"PHP Core"_
in parallel.

To collect more than the 1000 max results using this search API,
I vary the region string.

i.e.
#extra = "&region=uk"
#extra = "&region=ru"
#extra = "&region=fr"
#extra = "&region=es"
extra = "&region=sg" 

I check for duplicates later, and before downloading a file, so this is pretty safe.

 
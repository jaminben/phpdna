#!/usr/bin/ruby
#
#
##
#
# Converts data from a database into a graph
#
#
require "mysql"

OUTPUT = "output\/"

$dbh = Mysql.real_connect("localhost", "root", "", "php_info")
dbh = $dbh
# ok now run a query
# we really just need to run one join

require "graph"



def shutdown
  GC.start()
  # kind of a hack but ok
  cols = $cols
  dbh = $dbh
    cols.each do |c| 
    p c.nodes
      c.nodes.keys.each do |n|
      nod = n.to_s.gsub(/[^\d]/, "")
      nod_data = dbh.query("select url, query, path from sites where id =#{nod}")
      h = nod_data.fetch_hash
      if (h != nil )
        c.node_params = h.keys
        c.nodes[n] = h
      end
    end
  end

  #cols.first.filter


  cols.each do |x|
    #File.open("#{OUTPUT}#{x.class.to_s}.missed.net","w") do |f|
    #	f.puts x.to_net_directed("Missed Call")
    #end
    #File.open("#{OUTPUT}#{x.class.to_s}.incoming.net","w") do |f|
    #	f.puts x.to_net_directed("Outgoing")
    #end
    File.open("#{OUTPUT}#{x.class.to_s}.net","w") do |f|
      f.puts x.to_net_directed()
    end
    #File.open("#{OUTPUT}#{x.class.to_s}.duration.net","w") do |f|
    #	f.puts x.to_net_directed("duration")
    #end
  #
    File.open("#{OUTPUT}#{x.class.to_s}.gdf","w") do |f|
      f.puts x.to_guess_directed
    end
    #File.open("#{OUTPUT}#{x.class.to_s}.uni.gdf","w") do |f|
    #	f.puts x.to_guess_undirected
    #end
  #	x.print
    p x.max

    p "SAVED it here"
end	


end

trap("INT"){ shutdown }


class SimpleModuleGraphALL < Graph 

	def process(row)
		#
		# Maybe make a Bipartide Graph
		# between locations people make calls, and people?
		#
		key = :"#{row['from']}:#{row['to']}"
		
		@nodes[ row['from'].to_sym ] ||= {:name => 1}
		@nodes[ row['to'].to_sym ]   ||= {:name => 1}
	
		@edges[key] ||= Array.new

		# see if we already have this edge
		e = nil
		match = nil 
		#@edges[key].each do |d|
		#	if(row['location_oid'] == d.params['location_oid'])
		#		e = d
		#		match = true
		#	end
		#end
		
		e ||= Edge.new(row['from'].to_sym, row['to'].to_sym, self.param_names)

		e.params['common'] = row['common'].to_i 

		#e.params[ row['direction'] ]  += 1

		#e.params[ 'location' ]  = row['location'] 
		#e.params[ 'location_oid' ]  = row['location_oid'] 
		@edges[key] << e unless (match)
	
	end

	def param_names
		return ["common" ]
	end
end


# cols means collectors
$cols = Array.new
$cols << SimpleModuleGraphALL.new
cols = $cols
#cols << OnlyMissedCalls.new
#cols << FilteredNodesGraph.new
# add a bunch of collectors.. then at the end print them


#actually don't even need a join, this is trivial
#
# this should query all of the calls that are between people we are studying.
#res = dbh.query("select c.*,p.phonenumber_oid as my_phone  from callspan c, person p, person p1, cellspan cs, cellspan cs1 
#		 where p.oid = c.person_oid and p1.phonenumber_oid = c.phonenumber_oid 
#		 and p.oid = cs.person_oid and p1.oid = cs1.person_oid 
#		 and ((cs.starttime <= c.starttime and cs.endtime >= c.endtime) or (cs.starttime > c.starttime and c.endtime >= cs.starttime ) or (c.starttime <= cs.endtime and c.endtime > cs.endtime)) 
#		 and ((cs1.starttime <= c.starttime and cs1.endtime >= c.endtime) or (cs1.starttime > c.starttime and c.endtime >= cs1.starttime ) or (c.starttime <= cs1.endtime and c.endtime > cs1.endtime)) 
#		 order by starttime asc")

#res = dbh.query("select c.*,p.oid as poid, p1.oid as poid2,p.phonenumber_oid as my_phone  from callspan c, person p, person p1  where p.oid = c.person_oid and p1.phonenumber_oid = c.phonenumber_oid order by starttime asc")
res = dbh.query("select in_site_id as `from`, out_site_id as `to`, common from sedges where common > 44")
 
#res.each_hash do |row|
while row = res.fetch_hash do
		
	# ok .. do I want to ignore missed calls
	# [depends on the collector doesn't it]
	#	p row
	count ||= 0
	count = count + 1
	p count
  $stdout.flush
  # see if we are good
	#
  if count % 50 == 0
    GC.start()
    p "rinning collector"
  end	

if  row['common'].to_i > 6
  #check_is_good(row,dbh) 

	# this will be a conditional process
	# we have to do a query to see if they 
		cols.each do |x|
			x.process(row)
		end

	end	
end




# load this other crap:
#  select survey_Provider,survey_Neighborhood,survey_Position from person where phonenumber_oid=4;


shutdown
# need some method to output the graph in pyajek or whatever when I am done.
#
#
#or Guess format


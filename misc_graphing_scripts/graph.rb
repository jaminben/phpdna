class Edge
        attr_accessor :from, :to, :params

        def initialize(from, to, names = nil)
                @params = Hash.new
                @from   = from
                @to     = to

                if(names)
                        names.each do |x|
                                @params[x] =0
                        end
                end
        end
end


class Graph
        attr_accessor :nodes, :edges, :param_names, :node_params 
        def initialize
                @edges = Hash.new
                @nodes = Hash.new
		@param_names = []
        end

        def process( row )
                # given the row .. do something with it.
        end


        # something to generate a node list
        def export
                # takes nodes and edges.. and exports something nice
                p @nodes
                p @edges
        end

        def print
                # takes nodes and edges.. and exports something nice
                p @nodes
                p @edges
        end

	def Graph.load_from_guess (file, processfunc = nil) 
		newg = Graph.new
		node = false
		edge = false
		nparts = nil
		eparts = nil
		eparts2 = nil
		File.new(file,"r").each do |x|
			x = x.chomp
			if(x =~ /nodedef>/i) 
				dnparts = x.split(/>\s*/, 2).last.split(/\s*\,\s*/)
				nparts = Array.new		
				dnparts.each do |y|
					nparts << y.split(/\s\s*/).first
				end


				node = true
			elsif(x =~ /edgedef>/i) 
				departs = x.split(/>\s*/, 2).last.split(/\s*\,\s*/)
				eparts = Array.new		
				departs.each do |y|
					eparts << y.split(/\s\s*/).first
				end
				#ok.. make another copy and clean it
				eparts2 = eparts.clone 
				['node1','node2','directed','weight'].each { |xa| eparts2.delete(xa)} 
				newg.param_names = eparts2
				node = false
				edge = true
			elsif(node) 
				# a node oh my
				nn = x.split(/\s*\,\s*/)
				n = Hash.new
				c=0
				nn.each do |l|
					n[ nparts[c] ] = l
					c+=1	
				end		
					
				(newg.nodes[ n['name'] ] = n) if ( processfunc == nil || processfunc.check("node", n))  
			
			elsif(edge)
				#ok an edge
				ee = x.split(/\s*\,\s*/)

				return if (ee.length == 1)
				ep = Hash.new

				c=0
				ee.each do |l|
					ep[ eparts[c] ] = l
					c+=1	
				end
			
				e  = Edge.new(ep['node1'],ep['node2'],eparts2)
				e.params = ep	
				(newg.edges["#{ep['node1']}:#{ep['node2']}"] = e) if ( processfunc == nil || processfunc.check("edge", e))	
			end	
		end

		return newg

	end


        def to_guess_directed
                #returns a string that is the file to output.
                buffer = ""
	
                buffer = "nodedef> name"
       		#OK do this here
		@node_params ||= nodes[nodes.keys.first].keys.sort
		@node_params.delete("name")
		@node_params.delete(:name)
		@node_params.delete("name VARCHAR")
		p @node_params
		@node_params_type = Array.new
		@node_params.each { |x| @node_params_type << "VARCHAR"}

		c = 0
		@node_params.each do |np|
			buffer += "," + np.to_s
			buffer += " " + @node_params_type[c] unless np =~ /\s/
			c+=1
		end

		buffer += "\n"
	        nodes.keys.each do |n|
                        buffer += "n#{n}"         # may want to export more data later
                	@node_params.each do |np|
				buffer += "," + ( nodes[n][np].to_s  || "")
			end
			buffer += "\n"
		end

                buffer += "edgedef> node1, node2, directed, weight INT "

                self.param_names.each do  |x|
                        v = x.gsub(/\s/,"")
                        buffer += ",#{v} VARCHAR"
                end
                buffer += "\n"

                #ok now loop through all the edges and output them
		p @edges
                @edges.keys.each do |e|
			inner = [@edges[e]]
                        if(@edges[e].class == Array)
				inner = @edges[e]
			end
			inner.each do |ee|
				buffer += "n#{ee.from},n#{ee.to}, true, 1"
				self.param_names.each do  |x|
					buffer += ",#{ee.params[x]}"
				end
				buffer += "\n"
			end

                end

                return buffer
        end

        def to_guess_undirected
                #returns a string that is the file to output.
                buffer = ""
	
                buffer = "nodedef> name"
       		#OK do this here
		@node_params ||= nodes[nodes.keys.first].keys.sort
		@node_params.delete("name")
		@node_params.delete(:name)
		@node_params.delete("name VARCHAR")
		@node_params_type = Array.new
		@node_params.each { |x| @node_params_type << "VARCHAR"}

		c = 0
		@node_params.each do |np|
			buffer += "," + np.to_s
			buffer += " " + @node_params_type[c] unless np =~ /\s/
			c+=1
		end

		buffer += "\n"
	        nodes.keys.each do |n|
                        buffer += "n#{n}"         # may want to export more data later
                	@node_params.each do |np|
				buffer += "," + ( nodes[n][np].to_s  || "")
			end
			buffer += "\n"
		end

                buffer += "edgedef> node1, node2, directed, weight INT "

                self.param_names.each do  |x|
                        v = x.gsub(/\s/,"")
                        buffer += ",#{v} INT"
                end
                buffer += "\n"

                #ok now loop through all the edges and output them
                done = Hash.new
                @edges.keys.each do |e|
                        rev = "#{@edges[e].to}:#{@edges[e].from}"
                        next if ( done[rev] || done[e])
                        done[rev] = 1
                        done[e]   = 1

                        buffer += "n#{@edges[e].from},n#{@edges[e].to}, false, 1"
                        self.param_names.each do  |x|

                                buffer += ",#{@edges[e].params[x]}"
                        end
                        buffer += "\n"
                end

                return buffer
        end

        def to_net_directed(param = self.param_names.first)
                #returns a string that is the file to output.
                buffer = ""

		maxx = 0
		maxy = 0
		minx =0		
		miny =0		

		nodes.keys.each do |n|
			nod = nodes[n]
			begin
				maxx = nod['x'].to_f > maxx ? nod['x'].to_f : maxx  
				maxy = nod['y'].to_f > maxy ? nod['y'].to_f : maxy  
				miny = nod['y'].to_f < miny ? nod['y'].to_f : miny  
				minx = nod['x'].to_f < minx ? nod['x'].to_f : minx  
			rescue

				p $!
			end
		end
		maxx = maxx < 0? 0 - maxx: maxx
		maxy = maxy < 0? 0 - maxy: maxy
		miny = miny < 0 ? 0- miny : miny
		minx = minx < 0 ? 0 - minx : minx

		rangex = maxx - minx
		rangey = maxy - miny


                ali = Hash.new
                c = 1

                buffer = "*Vertices    #{nodes.keys.length}\r\n"
		nodes.keys.each do |n|
                       	begin
				if( nodes[n]['x'] != nil) 
					nx = nodes[n]['x'].to_f
					nx = nx < 0 ? 0-nx : nx
					ny = nodes[n]['y'].to_f
					ny = ny < 0 ? 0-ny : ny
					
					nx = 1 - (rangex - nx)/rangex
					ny = 1 - (rangey - ny)/rangey

					nx = nx.to_s.scan(/\d\d*\.\d\d\d\d/).first
					ny = ny.to_s.scan(/\d\d*\.\d\d\d\d/).first


				buffer += "#{c} \"n#{n}\" #{nx} #{ny} 0.5\r\n"         # may want to export more data later
			else
				buffer += "#{c} \"n#{n}\" 0 0 0\r\n"         # may want to export more data later
      end
			rescue
				p $!
				buffer += "#{c} \"n#{n}\" 0 0 0\r\n"         # may want to export more data later
			end
 
                        ali[n] = c
                        c += 1
                end

                buffer += "*Arcs\r\n"

                #ok now loop through all the edges and output them
                @edges.keys.each do |e|
			inner = [@edges[e]]
                        if(@edges[e].class == Array)
				inner = @edges[e]
                        end
			me = inner.first

			buffer += "#{ali[me.from]} #{ali[me.to]} #{me.params[param] != nil && me.params[param] != "0" && me.params[param] != ""   ? me.params[param] : 1 }\r\n"
                end

                buffer += "*Edges\r\n"
                return buffer
        end


        def param_names
                return @param_names 
        end
        def max
                return ""
        end
end

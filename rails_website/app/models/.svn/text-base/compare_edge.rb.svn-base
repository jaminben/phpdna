class CompareEdge < ActiveRecord::Base
      belongs_to :get_out, :class_name=> 'Pconfig', :foreign_key => :out_id
      belongs_to :get_in, :class_name=> 'Pconfig', :foreign_key => :in_id
      
      
      def get_edge(my_id)
        return self.get_out if (self.out_id != my_id)
        return self.get_in    
      end
      
      def get_edge_id(my_id)
        return self.out_id if (self.out_id != my_id)
        return self.in_id    
      end
      
end

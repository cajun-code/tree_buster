module CollectiveIdea #:nodoc:
  module Acts #:nodoc:
    module NestedSet
      module ClassMethods
        # Rebuilds the left & rights if unset or invalid.  Also very useful for converting from acts_as_tree.
        def rebuild!
          # Don't rebuild a valid tree.
          return true if valid?
          
          scope = lambda{|node|}
          if acts_as_nested_set_options[:scope]
            scope = lambda{|node| 
              scope_column_names.inject(""){|str, column_name|
                str << "AND #{connection.quote_column_name(column_name)} = #{connection.quote(node.send(column_name.to_sym))} "
              }
            }
          end
          indices = {}
          
          set_left_and_rights = lambda do |node|
            
            # set left
            left = indices[scope.call(node)] += 1            
            # find
            find(:all, :conditions => ["#{quoted_parent_column_name} = ? #{scope.call(node)}", node], :order => "#{quoted_left_column_name}, #{quoted_right_column_name}, #{acts_as_nested_set_options[:order]}").each{|n| set_left_and_rights.call(n) }
            node.reload
            #puts "node: #{node.id}"
            node[left_column_name] = left
            # set right
            node[right_column_name] = indices[scope.call(node)] += 1                            
            
            node.save(false)    
          end
                              
          # Find root node(s)
          root_nodes = find(:all, :conditions => "#{quoted_parent_column_name} IS NULL", :order => "#{quoted_left_column_name}, #{quoted_right_column_name}, #{acts_as_nested_set_options[:order]}").each do |root_node|
            # setup index for this scope          
            indices[scope.call(root_node)] ||= 0
            set_left_and_rights.call(root_node)
          end
        end
      end
    end
  end
end

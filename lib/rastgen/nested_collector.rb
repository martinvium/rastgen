# returns as soon as something is found, and returns 
class NestedCollector
  class << self
    def collect_nodes(ast, selector)
      patterns_matched = 0
      current_nodes = [ast]

      selector.patterns.each do |pattern|
        current_nodes = walk_nodes(current_nodes, pattern)

        if current_nodes.any?
          patterns_matched = patterns_matched + 1
        else
          break
        end
      end

      # did we reach the end?
      if patterns_matched == selector.patterns.count
        current_nodes
      else
        []
      end
    end

    def walk_nodes(nodes, pattern)
      found_nodes = []

      nodes.each do |node|
        next unless node.is_a? Parser::AST::Node 

        case node.type
        when :module, :class
          # second item is the name because the first would be a symbol for def?
          id_node = node.children.first
          if id_node.children[1] == pattern.identifier 
            found_nodes << node
          end
        when :def
          if node.children.first == pattern.identifier || pattern.any_id?
            found_nodes << node
          end
        end

        found_nodes = found_nodes + walk_nodes(node.children, pattern)
      end

      found_nodes
    end
  end

  # Validate your selector and return a struct with the selector and some
  # meta data about the result, but not the AST, since we need to change it
  # in place?
  # [
  #   [:module, :MyNS],
  #   [:class, :Endpoint]
  # ]
  # MyNS::Endpoint methods
  # Selector.modules(:MyNS).classes(:Endpoint).methods
  # def find_class(type, klass)
  #   parts = klass.name.split('::')
  #   klass = [:class, parts.pop.to_sym]

  #   qualified = parts.collect{ |p| [:module, p.to_sym] }
  #   qualified << klass

  #   found_nodes = []
  #   current_nodes = @ast

  #   qualified.each do |part|
  #     result = walk(current_nodes, part[0], part[1])
  #     if result
  #       current_nodes = result
  #       found_nodes << result
  #     end
  #   end

  #   if found_nodes.count == qualified.count
  #     found_nodes.last
  #   else
  #     nil
  #   end
  # end

end

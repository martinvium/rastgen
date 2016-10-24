class MoveMethodRewriter < Parser::Rewriter
  def initialize(class_name, method_nodes)
    @class_name = class_name
    @method_nodes = method_nodes
  end

  def on_class(node)
    return unless class_name? node
    insert_methods(node)
    super
  end

  private

  # TODO: fix indenting: https://whitequark.org/blog/2013/04/26/lets-play-with-ruby-code/
  # TODO: insert_loc is a Constant not a Definition, if no methods are defined, which fails
  def insert_methods(node)
    container_node = node_or_begin(node)

    insert_loc = child_nodes(container_node).last.loc
    source = "\n\n" + @method_nodes.collect{|n| Unparser.unparse(n) }.join("\n\n")

    if insert_loc.is_a? Parser::Source::Map::Definition
      insert_after(insert_loc.end, source)
    else
      raise 'only classes with at least one method already defined are supported'
    end
  end

  # NOTE: in some cases classes have a begin body, probably when there is some
  # static execution?
  def node_or_begin(node)
    if node.children[2].type == :begin
      node.children[2]
    else
      node
    end
  end

  def child_nodes(node)
    methods = node.children.select do |child|
      child.is_a? Parser::AST::Node
    end
  end

  def child_methods(node)
    methods = node.children.select do |child|
      node.type == :def
    end
  end

  def method?(node)
    (node.type == :def)
  end

  def class_name?(node)
    const = node.children.first
    raise 'not a const' unless const.type == :const

    const.children[1] == @class_name.to_sym
  end

end

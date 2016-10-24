class SourceFile
  attr_reader :source, :ast, :comments

  class << self
    def open(filename)
      source = File.read(filename)
      ast, comments = Parser::CurrentRuby.parse_with_comments(source)
      file = new(source, ast, comments)
      yield file if block_given?
      file
    end
  end

  def initialize(source, ast, comments)
    @source = source
    @ast = ast
    @comments = comments
  end

  def find(type, const)
    Selector.find(type, const)
  end

  def collect(selector)
    NestedCollector.collect_nodes(ast, selector)
  end

  # TODO: apply selector, when we are not able to traverse the tree?
  # returns the changes source
  def append(selector, new_nodes)
    pattern = selector.patterns.last

    # sanity check
    raise 'only classes can be the target of append' unless pattern.type == :class

    rewriter = MoveMethodRewriter.new(pattern.identifier, new_nodes)

    buffer = Parser::Source::Buffer.new('(example)')
    buffer.source = source

    rewriter.rewrite(buffer, ast)
  end

  def unparse
    Unparser.unparse(ast, comments)
  end
end

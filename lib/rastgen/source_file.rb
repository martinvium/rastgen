class SourceFile
  attr_reader :ast

  class << self
    def open(filename)
      source = File.read(filename)
      ast, comments = Parser::CurrentRuby.parse_with_comments(source)
      new(ast, comments)
    end
  end

  def initialize(ast, comments)
    @ast = ast
    @comments = comments
  end

  def find(type, const)
    Selector.find(type, const)
  end

  def collect(selector)
    NestedCollector.collect_nodes(@ast, selector)
  end
end

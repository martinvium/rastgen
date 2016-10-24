require 'spec_helper'

describe MoveMethodRewriter do
  it 'writes some code' do
    code = <<-EOF
      class DestinationClass
        def existing
          do_something
        end
      end
    EOF

    new_method = s(:def, :my_new_method, s(:args), nil)
    new_methods = [new_method]

    buffer        = Parser::Source::Buffer.new('(example)')
    buffer.source = code
    parser        = Parser::CurrentRuby.new
    ast           = parser.parse(buffer)
    rewriter      = described_class.new(:DestinationClass, new_methods)

    out = rewriter.rewrite(buffer, ast)

    # Rewrite the AST, returns a String with the new form.
    expect(out).to eq(<<-EOF
      class DestinationClass
        def existing
          do_something
        end

def my_new_method
end
      end
    EOF
    )
  end

  it 'inserts method with begin block' do
    code = <<-EOF
      class DestinationClass
        attr_accessor :some_attr

        def existing
          do_something
        end
      end
    EOF

    new_method = s(:def, :my_new_method, s(:args), nil)
    new_methods = [new_method]

    buffer        = Parser::Source::Buffer.new('(example)')
    buffer.source = code
    parser        = Parser::CurrentRuby.new
    ast           = parser.parse(buffer)
    rewriter      = described_class.new(:DestinationClass, new_methods)

    out = rewriter.rewrite(buffer, ast)

    # Rewrite the AST, returns a String with the new form.
    expect(out).to eq(<<-EOF
      class DestinationClass
        attr_accessor :some_attr

        def existing
          do_something
        end

def my_new_method
end
      end
    EOF
    )
  end

  def s(type, *children)
    Parser::AST::Node.new(type, children)
  end
end

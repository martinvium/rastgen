require "spec_helper"

describe Rastgen do
  let(:endpoint_source_filename) { './spec/fixtures/endpoint.rb' }
  let(:model_source_filename) { './spec/fixtures/model.rb' }

  subject do
    SourceFile.open(endpoint_source_filename)
  end

  it "has a version number" do
    expect(Rastgen::VERSION).not_to be nil
  end

  it 'returns explicit method' do
    selector = subject.find(:module, :MyNS).find(:class, :Endpoint).find(:def, :initialize)
    nodes = subject.collect(selector)

    expect(nodes.count).to eq(1)
    expect(nodes.first.type).to eq(:def)
    expect(nodes.first.children.first).to eq(:initialize)
  end

  it 'returns any method' do
    selector = subject.find(:module, :MyNS).find(:class, :Endpoint).find(:def)
    nodes = subject.collect(selector)

    expect(nodes.count).to eq(4)
    expect(nodes[0].type).to eq(:def)
    expect(nodes[1].type).to eq(:def)
    expect(nodes[2].type).to eq(:def)
    expect(nodes[3].type).to eq(:def)
  end

  # FIXME: will add #{} around /resources/ for some reason, probably unparse
  # is doing it because it is unable to interpret the source otherwise...
  xit 'moves the method' do
    selector = subject.find(:module, :MyNS).find(:class, :Endpoint).find(:def, :get)
    nodes = subject.collect(selector)

    SourceFile.open(model_source_filename) do |f|
      selector = f.find(:class, :Model)
      out = f.append(selector, nodes)
      expect(out).to eq(<<'EOF'
class Model
  attr_accessor :connection
  attr_accessor :id
  attr_accessor :created_at
  attr_accessor :currency

  def some_helper
    currency
  end

def get(id)
  data = connection.get("/resources/#{id}").body
  build(data)
end
end
EOF
     )
    end
  end
end

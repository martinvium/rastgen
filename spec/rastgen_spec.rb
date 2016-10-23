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

    expect(nodes.count).to eq(3)
    expect(nodes[0].type).to eq(:def)
    expect(nodes[1].type).to eq(:def)
    expect(nodes[2].type).to eq(:def)
  end

  it 'inserts' do
    # SourceFile.open(model_source_filename) do |f|
    #   f.classSelf do |scope|
    #     scope.append(methods)
    #   end
    # end
  end
end

module MyNS
  class Endpoint
    attr_accessor :connection

    def initialize(connection)
      @connection = connection
    end

    def get(id)
      data = connection.get("/resources/#{id}").body
      build(data)
    end

    def build(data)
      Model.new({ connection: connection }.merge(data))
    end

    def empty
    end
  end
end

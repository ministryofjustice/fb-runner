module Platform
  class ClientError < StandardError
    def initialize(exception)
      @exception = exception

      super(exception)
    end

    def response
      @exception.response
    end
  end
end

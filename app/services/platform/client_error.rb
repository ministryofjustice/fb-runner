module Platform
  class ClientError < StandardError
    def initialize(exception)
      @exception = exception

      super(exception)
    end

    delegate :response, to: :@exception
  end
end

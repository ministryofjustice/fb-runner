module Userdata
  class Memory
    attr_reader :id

    def initialize(id)
      @id = id
    end

    def read
      Rails.cache.read(id) || {}
    end

    def write(data)
      Rails.cache.write(id, data)
    end

    def merge(new_data)
      data = Rails.cache.read(id) || {}
      data.merge!(new_data)
      write(data)
    end
  end
end

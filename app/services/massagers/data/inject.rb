module Massagers
  module Data
    class Inject
      attr_reader :hash, :data

      def initialize(hash:, data:)
        @hash = hash
        @data = data
      end

      def call
        data.read.each do |k,v|
          (hash[:page][:components] || []).each do |component|
            if component[:name] == k
              component[:value] = v
            end
          end
        end
      end
    end
  end
end

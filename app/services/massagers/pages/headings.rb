module Massagers
  module Pages
    class Headings
      attr_reader :in_hash, :out_hash

      def initialize(in_hash:, out_hash:)
        @in_hash = in_hash
        @out_hash = out_hash
      end

      def call
        if in_hash['page']['heading']
          out_hash['page']['heading'] = in_hash['page']['heading']
        end

        if in_hash['page']['sectionHeading']
          out_hash['page']['sectionHeading'] = in_hash['page']['sectionHeading']
        end
      end
    end
  end
end

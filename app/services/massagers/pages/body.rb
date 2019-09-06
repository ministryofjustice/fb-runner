module Massagers
  module Pages
    class Body
      attr_reader :in_hash, :out_hash

      def initialize(in_hash:, out_hash:)
        @in_hash = in_hash
        @out_hash = out_hash
      end

      def call
        if in_hash['page']['body']
          markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
          out_hash['page']['body'] = markdown.render(in_hash['page']['body'])
        end
      end
    end
  end
end

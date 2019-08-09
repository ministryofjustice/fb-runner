module Massagers
  module Pages
    class Body
      attr_reader :hash

      def initialize(hash:)
        @hash = hash
      end

      def call
        if hash['page']['body']
          markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
          hash['page']['body'] = markdown.render(hash['page']['body'])
        end
      end
    end
  end
end

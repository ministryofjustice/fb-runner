module Massagers
  module Pages
    class Previous
      attr_reader :hash, :service, :page

      def initialize(hash:, service:, page:)
        @hash = hash
        @service = service
        @page = page
      end

      def call
        if previous_page
          if hash['page']
            hash['page']['previouspage'] = previous_page.url
          end
        end
      end

      private

      def previous_page
        @previous_page ||= Flow.new(service: service, page: page).previous_page
      end
    end
  end
end

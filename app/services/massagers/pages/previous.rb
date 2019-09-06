module Massagers
  module Pages
    class Previous
      attr_reader :in_hash, :out_hash, :service, :page

      def initialize(in_hash:, out_hash:, service:, page:)
        @in_hash = in_hash
        @out_hash = out_hash
        @service = service
        @page = page
      end

      def call
        if previous_page
          if out_hash['page']
            out_hash['page']['previouspage'] = previous_page.url
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

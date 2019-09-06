module Massagers
  module Pages
    class Header
      attr_reader :in_hash, :out_hash

      def initialize(in_hash:, out_hash:)
        @in_hash = in_hash
        @out_hash = out_hash
      end

      def call
        if out_hash['page']
          out_hash['page']['header'] = {
            "$source": "@ministryofjustice/fb-components-core",
            "_id": "config.header",
            "_type": "header",
            "description": "Base header for govuk template",
            "homepageUrl": "https://www.gov.uk",
            "serviceName": "Interests of Justice",
            "serviceUrl": "/",
            "$component": true,
            "$content": true,
            "$definition": true,
            "assetsPath": "/assets/images",
            "show": true
          }
        end
      end
    end
  end
end

module Massagers
  module Components
    class Fileupload
      attr_reader :hash

      def initialize(hash:)
        @hash = hash
      end

      def call
        (hash[:page][:components] || []).each do |c|
          if c[:_type] == "fileupload"
            c[:fileUploads] = [
              {
                "$skipValidation": true,
                "$originalName": "documentation",
                "name": "documentation[1]",
                "label": "Attach any documentation that supports your appeal",
                "hint": "\n\n\n\nMaximum size: 7MB per file\n\nYour document will upload when you click ‘Continue’."
              }
            ]
          end
        end
      end
    end
  end
end

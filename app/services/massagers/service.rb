module Massagers
  class Service
    attr_reader :in_hash, :out_hash

    def initialize(in_hash:, out_hash:)
      @in_hash = in_hash
      @out_hash = out_hash
    end

    def call
      if out_hash['page']
        out_hash['page']['service'] = {
          "$source": "service",
          "_id": "service",
          "_type": "config.service",
          "code": "IOJ",
          "emailInputNameUser": "solicitor_email",
          "emailSubjectTeam": "IoJ application - {fullname}",
          "emailSubjectUser": "Your IoJ application has been submitted",
          "emailTemplateTeam": "Please find an application attached",
          "emailTemplateUser": "Dear {fullname}\r\n\r\nA copy of your IoJ application is attached.",
          "name": "Interests of Justice",
          "pdfHeading": "Application against a refusal of criminal legal aid on interests of justice grounds",
          "pdfSubHeading": "IOJ",
          "phase": "alpha",
          "phaseText": "Send your feedback here",
          "_isa": "@ministryofjustice/fb-components-core=>service",
          "dataRetentionDuration": 28,
          "homepageUrl": "https://www.gov.uk",
          "serviceEmailAddress": "form-builder@digital.justice.gov.uk",
          "serviceUrl": "page.start",
          "sessionDuration": 30,
          "$configuration": true,
          "$definition": true,
          "languageDefault": "en"
        }
      end
    end
  end
end

class Service
  attr_reader :raw_metadata

  def initialize
    @raw_metadata = {
      "service_id": "634aa3d5-a3b3-4d0f-9078-bb754542a1d3",
      "service_name" => "Service Name",
      "version_id": "ac4b45c5-071e-4d07-b5a2-9f0196a5b267",
      "created_at": "2020-10-09T11:51:46",
      "created_by": "4634ec01-5618-45ec-a4e2-bb5aa587e751",
      "configuration": {
        "_id": "service",
        "_type": "config.service"
      },
      "pages" => [
        { "_id" => "page.start",
          "_type" => "page.start",
          "body" => "You cannot use this form to complain about:\r\n\r\n* the result of a case\r\n* a judge, magistrate, coroner or member of a tribunal\r\n\r\nThis online form is also available in [Welsh (Cymraeg)](https://complain-about-a-court-or-tribunal.form.service.justice.gov.uk/cy).",
          "heading" => "Complain about a court or tribunal",
          "lede" => "Your complaint will not affect your case.",
          "steps" => [
            "page-2",
            "page.do-you-have-a-case-number"
          ],
          "url" => "/"
        },
        {
          "_id" => "page-2",
          "_type" => "page",
          "body" => "This is page two",
          "url" => "/page-2"
        }
      ],
      "locale" => "en"
    }
  end

  def service_id
    raw_metadata['service_id']
  end

  def service_name
    raw_metadata['service_name']
  end

  def version_id
    raw_metadata['version_id']
  end

  def created_at
    raw_metadata['created_at']
  end

  def created_by
    raw_metadata['created_by']
  end

  def pages
    raw_metadata['pages'].map do |page|
      Page.new(page)
    end
  end

  def configuration
    raw_metadata['configuration']
  end

  def locale
    raw_metadata['locale']
  end

  def render
    ApplicationController.render(template: 'service/start')
  end
end

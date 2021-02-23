module Platform
  class SubmitterPayload
    attr_reader :service, :user_data

    def initialize(service:, user_data:)
      @service = service
      @user_data = user_data
    end

    def to_h
      {
        meta: meta,
        service: service_info,
        actions: actions,
        pages: pages
      }
    end

    def service_info
      {
        id: service.service_id,
        slug: service.service_slug,
        name: service.service_name
      }
    end

    def meta
      {
        pdf_heading: ENV['SERVICE_EMAIL_PDF_HEADING'].to_s,
        pdf_subheading: ENV['SERVICE_EMAIL_PDF_SUBHEADING'].to_s
      }
    end

    def actions
      [
        {
          kind: 'email',
          to: ENV['SERVICE_EMAIL_OUTPUT'].to_s,
          from: ENV['SERVICE_EMAIL_SENDER'].to_s,
          subject: ENV['SERVICE_EMAIL_SUBJECT'].to_s,
          email_body: ENV['SERVICE_EMAIL_BODY'].to_s,
          include_pdf: true
        }
      ]
    end

    def pages
      service.pages.map do |page|
        next if page.components.blank?

        {
          heading: '',
          answers: page.components.map do |component|
            {
              field_id: component.id,
              field_name: component.humanised_title,
              answer: answer_for(page, component)
            }
          end
        }
      end.compact
    end

    def answer_for(page, component)
      page_answers = MetadataPresenter::PageAnswers.new(page, user_data)
      answer = page_answers.send(component.id)

      if answer.is_a?(MetadataPresenter::DateField) && answer.present?
        # how can we reuse the presenter code? Module?
        I18n.l(
          Date.civil(answer.year.to_i, answer.month.to_i, answer.day.to_i),
          format: '%d %B %Y'
        )
      else
        answer
      end
    end
  end
end

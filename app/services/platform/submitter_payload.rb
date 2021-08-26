module Platform
  class SubmitterPayload
    include Platform::Connection
    attr_reader :service, :user_data, :session

    EMAIL = 'email'.freeze

    def initialize(service:, user_data:, session:)
      @service = service
      @user_data = user_data
      @session = session
    end

    def to_h
      {
        meta: meta,
        service: service_info,
        actions: actions,
        pages: pages,
        attachments: attachments
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
        pdf_heading: ENV['SERVICE_EMAIL_PDF_HEADING'],
        pdf_subheading: ENV['SERVICE_EMAIL_PDF_SUBHEADING'].to_s
      }
    end

    def actions
      [
        {
          kind: EMAIL,
          to: ENV['SERVICE_EMAIL_OUTPUT'],
          from: ENV['SERVICE_EMAIL_FROM'],
          subject: ENV['SERVICE_EMAIL_SUBJECT'],
          email_body: ENV['SERVICE_EMAIL_BODY'],
          include_pdf: true,
          include_attachments: true
        }
      ]
    end

    def pages
      answered_pages.map { |page|
        components = strip_content_components(page.components)
        next if components.empty?

        {
          heading: heading(page),
          answers: components.map do |component|
            {
              field_id: component.id,
              field_name: component.humanised_title,
              answer: answer_for(page, component)
            }
          end
        }
      }.compact
    end

    def answered_pages
      MetadataPresenter::TraversedPages.new(service, user_data).all
    end

    def answer_for(page, component)
      page_answers = MetadataPresenter::PageAnswers.new(page, user_data)
      answer = page_answers.send(component.id)

      if answer.is_a?(MetadataPresenter::DateField)
        return '' if answer.blank?

        # how can we reuse the presenter code? Module?
        I18n.l(
          Date.civil(answer.year.to_i, answer.month.to_i, answer.day.to_i),
          format: '%d %B %Y'
        )
      elsif component.type == 'checkboxes'
        answer.to_a
      elsif component.upload?
        answer['original_filename'] || ''
      else
        answer
      end
    end

    def heading(page)
      page.type == 'page.multiplequestions' ? page.heading : ''
    end

    def attachments
      answered_upload_components.map do |component|
        {
          url: file_download_url(component['fingerprint']),
          filename: component['original_filename'],
          mimetype: component['type'] || component['content_type']
        }
      end
    end

    private

    def strip_content_components(components)
      return [] if components.blank?

      components.reject(&:content?)
    end

    def answered_upload_components
      upload_components.map { |component| user_data[component.id] }.compact.reject(&:blank?)
    end

    def upload_components
      components = service.pages.map do |page|
        page.components&.select(&:upload?)
      end
      components.flatten.compact
    end

    def file_download_url(fingerprint)
      "#{ENV['USER_FILESTORE_URL']}" \
      "/service/#{ENV['SERVICE_SLUG']}" \
      "/user/#{user_id}" \
      "/#{fingerprint}"
    end
  end
end

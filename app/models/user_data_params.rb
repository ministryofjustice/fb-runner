class UserDataParams
  def initialize(page_answers)
    @page_answers = page_answers
    @answer_params = params_hash
  end

  def answers
    set_uploaded_file_details
    set_optional_checkboxes

    answer_params
  end

  private

  attr_reader :page_answers, :answer_params

  def params_hash
    answers = page_answers.answers

    # `answers` can also be a `MetadataPresenter::MultiUploadAnswer`, thus this check
    answers.permit! if answers.is_a?(ActionController::Parameters)
    answers.to_h
  end

  def set_uploaded_file_details
    page_answers.uploaded_files.map do |uploaded_file|
      component_id = uploaded_file.component.id
      answer = page_answers.send(component_id)
      file = uploaded_file.file

      # Temporary workaround until we know more about an edge case
      begin
        file.to_h
      rescue ActionController::UnfilteredParameters => e
        Sentry.set_context(
          'debug', {
            file: ActiveSupport::ParameterFilter.new(%i[tempfile filename]).filter(file).inspect
          }
        )
        Sentry.capture_exception(e)

        # Continue by permitting the file attributes, user will not see an error
        file.permit!
      end

      if uploaded_file.component.type == 'multiupload'
        # merge the uploaded file into the last file in the component
        answer_params[component_id][-1] = answer[component_id].last.merge(file)
      else
        answer_params[component_id] = answer.merge(file)
      end
    end
  end

  def set_optional_checkboxes
    checkbox_components.each do |component|
      answer_params[component.id] = [] if page_answers.send(component.id).blank?
    end
  end

  def checkbox_components
    # not all pages have components
    Array(page_answers.page.components).select do |component|
      component.type == 'checkboxes'
    end
  end
end

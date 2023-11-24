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
    if page_answers.uploaded_files.present?
      page_answers.uploaded_files.map do |uploaded_file|
        if uploaded_file.component.type == 'multiupload'
          # merge the uploaded file into the last file in the component
          answer_params[uploaded_file.component.id][-1] =
            page_answers.send(uploaded_file.component.id)[uploaded_file.component.id].last.merge(uploaded_file.file)
        else
          answer_params[uploaded_file.component.id] =
            page_answers.send(uploaded_file.component.id).merge(uploaded_file.file)
        end
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

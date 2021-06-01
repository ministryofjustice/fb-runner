class UserDataParams
  def initialize(page_answers)
    @page_answers = page_answers
    @answer_params = @page_answers.answers.to_h
  end

  def answers
    if @page_answers.uploaded_files.present?
      @page_answers.uploaded_files.map do |uploaded_file|
        @answer_params[uploaded_file.component.id] =
          @page_answers.send(uploaded_file.component.id).merge(uploaded_file.file)
      end
    end

    @answer_params
  end
end

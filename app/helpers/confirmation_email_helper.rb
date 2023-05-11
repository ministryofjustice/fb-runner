module ConfirmationEmailHelper
  include ActionView::Context
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper

  def answers_html(pages)
    table_heading + answers_table(pages)
  end

  def table_heading
    tag.h2('Your answers')
  end

  def heading_row(content)
    tag.tr(tag.td(content, colspan: 2, style: 'font-weight: bold; font-size: 24px;'))
  end

  def answers_table(pages)
    tag.table do
      pages.collect { |page|
        concat(heading_row(page[:heading])) if page[:heading].present?

        page[:answers].collect { |answer|
          concat answer_row(answer[:field_name], human_value(answer[:answer]))
        }.join.html_safe
      }.join.html_safe
    end
  end

  def answer_row(question, answer)
    tag.tr(question_cell(question) + answer_cell(answer))
  end

  def question_cell(content)
    tag.td(content, style: 'font-weight: bold;')
  end

  def answer_cell(content)
    tag.td(content, style: '')
  end

  def human_value(answer)
    answer.is_a?(Array) ? answer.join("\n\n") : answer
  end
end

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
    tag.tr do
      tag.td colspan: 2, style: inline_style_string(heading_styles) do
        content
      end
    end
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
    tag.td(content, style: inline_style_string(cell_styles.merge(question_styles)))
  end

  def answer_cell(content)
    tag.td(content, style: inline_style_string(cell_styles.merge(answer_styles)))
  end

  def human_value(answer)
    answer.is_a?(Array) ? answer.join("\n\n") : answer
  end

  def inline_style_string(attributes)
    attributes.reduce('') { |str, (prop, val)| str + "#{prop.to_s.dasherize}: #{val}; " }.rstrip
  end

  def heading_styles
    {
      font_size: '20px',
      padding_top: '15px',
      padding_bottom: '15px'
    }
  end

  def question_styles
    {
      font_weight: 'bold',
      padding_right: '5px'
    }
  end

  def answer_styles
    {
      padding_left: '5px'
    }
  end

  def cell_styles
    {
      width: '50%',
      padding_top: '5px',
      padding_bottom: '5px',
      border_bottom: '1px solid #C4C4C4',
      vertical_align: 'top'
    }
  end
end

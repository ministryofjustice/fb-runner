module ConfirmationEmailHelper
  include ActionView::Context
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper

  STYLES = {
    heading: {
      padding_top: '20px',
      padding_bottom: '15px'
    },
    cell: {
      width: '50%',
      padding_top: '5px',
      padding_bottom: '5px',
      border_bottom: '1px solid #C4C4C4',
      vertical_align: 'top'
    },
    question: {
      font_weight: 'bold',
      padding_right: '5px'
    },
    answer: {
      padding_left: '5px'
    }
  }.freeze

  def answers_html(pages)
    table_heading + answers_table(pages)
  end

  def table_heading
    tag.h2('Your answers')
  end

  def heading_row(content)
    tag.tr do
      tag.td colspan: 2, style: heading_styles do
        tag.h3 content, style: 'margin: 0 !important;'
      end
    end
  end

  def answers_table(pages)
    tag.table do
      pages.collect { |page|
        concat(heading_row(page[:heading])) if page[:heading].present?

        page[:answers].collect { |answer|
          concat answer_row(answer[:field_name], answer[:answer])
        }.join.html_safe
      }.join.html_safe
    end
  end

  def answer_row(question, answer)
    tag.tr(question_cell(question) + answer_cell(answer))
  end

  def question_cell(content)
    tag.td(content, style: question_styles)
  end

  def answer_cell(content)
    tag.td(content, style: answer_styles)
  end

  def heading_styles
    inline_style_string(STYLES[:heading])
  end

  def question_styles
    inline_style_string(STYLES[:cell].merge(STYLES[:question]))
  end

  def answer_styles
    inline_style_string(STYLES[:cell].merge(STYLES[:answer]))
  end

  def inline_style_string(attributes)
    attributes.reduce('') { |str, (prop, val)| str + "#{prop.to_s.dasherize}: #{val}; " }.rstrip
  end
end

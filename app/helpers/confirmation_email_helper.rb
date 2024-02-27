module ConfirmationEmailHelper
  include ActionView::Context
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper

  def styles
    {
      heading_row: {
        padding_top: '20px',
        padding_bottom: '10px'
      },
      h3: {
        margin: '0 !important'
      },
      cell: {
        width: '50%',
        padding_top: '5px',
        padding_bottom: '5px',
        border_bottom: '1px solid #C4C4C4',
        vertical_align: 'top'
      },
      question_cell: {
        font_weight: 'bold',
        padding_right: '5px'
      },
      answer_cell: {
        padding_left: '5px'
      },
      first_row_cell: {
        padding_top: '20px'
      }
    }.freeze
  end

  def answers_html(pages, heading:)
    if heading
      table_heading + answers_table(pages)
    else
      answers_table(pages, style: 'margin-top: 40px')
    end
  end

  def table_heading
    tag.h2(I18n.t('presenter.confirmation_email.table_heading'))
  end

  def heading_row(content)
    tag.tr do
      tag.td colspan: 2, style: heading_row_styles do
        tag.h3 content, style: h3_styles
      end
    end
  end

  def answers_table(pages, style: nil)
    tag.table(style:) do
      previous_page_was_multiquestion = false
      pages.collect { |page|
        concat(heading_row(page[:heading])) if page[:heading].present?
        page[:answers].each.collect { |answer|
          if multiquestion_page?(page[:answers])
            concat answer_row(question: answer[:field_name], answer: answer[:answer])
            previous_page_was_multiquestion = true
          else
            concat answer_row(question: answer[:field_name], answer: answer[:answer], first_row: previous_page_was_multiquestion)
            previous_page_was_multiquestion = false
          end
        }.join.html_safe
      }.join.html_safe
    end
  end

  def answer_row(question:, answer:, first_row: false)
    tag.tr(question_cell(content: question, first_row:) + answer_cell(content: answer, first_row:))
  end

  def question_cell(content:, first_row: false)
    tag.td(content, style: question_cell_styles(first_row:))
  end

  def answer_cell(content:, first_row: false)
    answer = content.is_a?(Hash) ? content.values.compact_blank.join(', ') : content
    tag.td(answer, style: answer_cell_styles(first_row:))
  end

  def heading_row_styles
    inline_style_string(styles[:heading_row])
  end

  def h3_styles
    inline_style_string(styles[:h3])
  end

  def question_cell_styles(first_row: false)
    question_styles = styles[:cell].merge(styles[:question_cell])
    question_styles.merge!(styles[:first_row_cell]) if first_row
    inline_style_string(question_styles)
  end

  def answer_cell_styles(first_row: false)
    answer_styles = styles[:cell].merge(styles[:answer_cell])
    answer_styles.merge!(styles[:first_row_cell]) if first_row
    inline_style_string(answer_styles)
  end

  def inline_style_string(attributes)
    return '' unless attributes.is_a? Hash

    attributes.reduce('') { |str, (prop, val)| str + "#{prop.to_s.dasherize}: #{val}; " }.rstrip
  end

  def multiquestion_page?(answers)
    answers.size > 1
  end
end

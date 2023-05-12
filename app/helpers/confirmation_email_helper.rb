module ConfirmationEmailHelper
  include ActionView::Context
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper

  def styles
    {
      table: {
        width: '100%',
        border_collapse: 'collapse'
      },
      multiquestion_table: {
        margin_bottom: '20px'
      },
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
      last_row_cell: {
        padding_bottom: '20px'
      }
    }.freeze
  end

  def answers_html(pages)
    table_heading + answers_table(pages)
  end

  def table_heading
    tag.h2('Your answers')
  end

  def heading_row(content)
    tag.tr do
      tag.td colspan: 2, style: heading_row_styles do
        tag.h3 content, style: h3_styles
      end
    end
  end

  def answers_table(pages)
    tag.table('cell-padding': 0, 'cell-spacing': 0, style: table_styles) do
      pages.collect { |page|
        if page[:answers].size > 1
          concat(multiquestion_page_row(page))
        else
          answer_rows(page[:answers])
        end
      }.join.html_safe
    end
  end

  def multiquestion_page_row(page)
    tag.tr do
      tag.td(colspan: 2) do
        multiquestion_page_answers_table(page)
      end
    end
  end

  def multiquestion_page_answers_table(page)
    tag.table('cell-padding': 0, 'cell-spacing': 0, style: multiquestion_table_styles) do
      concat(heading_row(page[:heading])) if page[:heading].present?
      answer_rows(page[:answers])
    end
  end

  def answer_rows(answers)
    answers.each_with_index.collect { |answer, _index|
      concat answer_row(question: answer[:field_name], answer: answer[:answer])
    }.join.html_safe
  end

  def answer_row(question:, answer:, last_row: false)
    tag.tr(question_cell(content: question, last_row:) + answer_cell(content: answer, last_row:))
  end

  def question_cell(content:, last_row: false)
    tag.td(content, style: question_cell_styles(last_row:))
  end

  def answer_cell(content:, last_row: false)
    tag.td(content, style: answer_cell_styles(last_row:))
  end

  def table_styles
    inline_style_string(styles[:table])
  end

  def heading_row_styles
    inline_style_string(styles[:heading_row])
  end

  def h3_styles
    inline_style_string(styles[:h3])
  end

  def question_cell_styles(last_row: false)
    question_styles = styles[:cell].merge(styles[:question_cell])
    question_styles.merge!(styles[:last_row_cell]) if last_row
    inline_style_string(question_styles)
  end

  def answer_cell_styles(last_row: false)
    answer_styles = styles[:cell].merge(styles[:answer_cell])
    answer_styles.merge!(styles[:last_row_cell]) if last_row
    inline_style_string(answer_styles)
  end

  def multiquestion_table_styles
    inline_style_string(styles[:table].merge(styles[:multiquestion_table]))
  end

  def inline_style_string(attributes)
    return '' unless attributes.is_a? Hash

    attributes.reduce('') { |str, (prop, val)| str + "#{prop.to_s.dasherize}: #{val}; " }.rstrip
  end

  def last_answer_on_multiquestion_page(answers, index)
    answers.size > 1 && index == answers.size - 1
  end
end

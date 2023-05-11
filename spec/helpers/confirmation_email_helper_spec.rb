RSpec.describe ConfirmationEmailHelper do
  let(:pages) do
    [
      {
        answers: [
          { field_name: 'Question 1', answer: 'Answer 1' },
          { field_name: 'Question 2', answer: 'Answer 2' }
        ]
      },
      {
        heading: 'Page Heading',
        answers: [
          { field_name: 'Question 3', answer: 'Answer 3' },
          { field_name: 'Question 4', answer: 'Answer 4' }
        ]
      }
    ]
  end

  describe '#table_header'
  it 'should build the h2' do
    expect(helper.table_heading).to eql '<h2>Your answers</h2>'
  end

  describe '#inline_style_string' do
    let(:styles) { { font_weight: 'bold', font_size: '24px' } }

    it 'should genrate a style string from hash' do
      expect(helper.inline_style_string(styles)).to eql 'font-weight: bold; font-size: 24px;'
    end
  end

  describe '#human_value' do
    let(:arry) { %w[one two three] }

    it 'should join array values with newlines' do
      expect(helper.human_value(arry)).to eql "one\n\ntwo\n\nthree"
    end

    it 'should pass through string values' do
      expect(helper.human_value('string')).to eql 'string'
    end
  end

  describe '#answer_cell' do
    it 'generates the table cell html with merged styles' do
      allow(helper).to receive(:cell_styles).and_return({ color: 'red' })
      allow(helper).to receive(:answer_styles).and_return({ font_size: '100px' })

      expect(helper.answer_cell('answer')).to eql '<td style="color: red; font-size: 100px;">answer</td>'
    end
  end

  describe '#question_cell' do
    it 'generates the table cell html with merged styles' do
      allow(helper).to receive(:cell_styles).and_return({ color: 'red' })
      allow(helper).to receive(:question_styles).and_return({ font_size: '100px' })

      expect(helper.question_cell('question')).to eql '<td style="color: red; font-size: 100px;">question</td>'
    end
  end

  describe '#answer_row' do
    it 'generates the table row html with merged styles' do
      allow(helper).to receive(:cell_styles).and_return({ color: 'red' })
      allow(helper).to receive(:answer_styles).and_return({ font_size: '100px' })
      allow(helper).to receive(:question_styles).and_return({ width: '50%' })

      expect(helper.answer_row('question', 'answer')).to eql '<tr><td style="color: red; width: 50%;">question</td><td style="color: red; font-size: 100px;">answer</td></tr>'
    end
  end

  describe '#answers_table' do
    let(:q1) { '<td style="color: red; width: 50%;">Question 1</td>' }
    let(:a1) { '<td style="color: red; font-size: 100px;">Answer 1</td>' }
    let(:q2) { '<td style="color: red; width: 50%;">Question 2</td>' }
    let(:a2) { '<td style="color: red; font-size: 100px;">Answer 2</td>' }
    let(:heading) { '<td colspan="2" style="color: blue;">Page Heading</td>' }
    let(:q3) { '<td style="color: red; width: 50%;">Question 3</td>' }
    let(:a3) { '<td style="color: red; font-size: 100px;">Answer 3</td>' }
    let(:q4) { '<td style="color: red; width: 50%;">Question 4</td>' }
    let(:a4) { '<td style="color: red; font-size: 100px;">Answer 4</td>' }

    it 'generates the table html' do
      allow(helper).to receive(:cell_styles).and_return({ color: 'red' })
      allow(helper).to receive(:answer_styles).and_return({ font_size: '100px' })
      allow(helper).to receive(:question_styles).and_return({ width: '50%' })
      allow(helper).to receive(:heading_styles).and_return({ color: 'blue' })
      # "<table>
      #       <tr>
      #       <td style=\"color: red; width: 50%;\">Question 1</td>
      #       <td style=\"color: red; font-size: 100px;\">Answer 1</td>
      #       </tr>
      #       <tr>
      #       <td style=\"color: red; width: 50%;\">Question 2</td>
      #       <td style=\"color: red; font-size: 100px;\">Answer 2</td>
      #       </tr>
      #       <tr>
      #       <td colspan=\"2\" style=\"color: blue;\">Page Heading</td>
      #       </tr>
      #       <tr>
      #       <td style=\"color: red; width: 50%;\">Question 3</td>
      #       <td style=\"color: red; font-size: 100px;\">Answer 3</td>
      #       </tr>
      #       <tr>
      #       <td style=\"color: red; width: 50%;\">Question 4</td>
      #       <td style=\"color: red; font-size: 100px;\">Answer 4</td>
      #       </tr>
      #       </table>"
      #       byebug
      expect(helper.answers_table(pages)).to eql "<table><tr>#{q1}#{a1}</tr><tr>#{q2}#{a2}</tr><tr>#{heading}</tr><tr>#{q3}#{a3}</tr><tr>#{q4}#{a4}</tr></table>"
    end
  end
end

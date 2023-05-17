RSpec.describe ConfirmationEmailHelper do
  let(:pages) do
    [
      {
        answers: [
          { field_name: 'Question 1', answer: 'Answer 1' }
        ]
      },
      {
        answers: [
          { field_name: 'Question 2', answer: 'Answer 2' }
        ]
      },
      {
        heading: 'Page Heading',
        answers: [
          { field_name: 'Question 3', answer: 'Answer 3' },
          { field_name: 'Question 4', answer: 'Answer 4' }
        ]
      },
      {
        answers: [
          { field_name: 'Question 5', answer: 'Answer 5' }
        ]
      }
    ]
  end

  let(:test_styles) do
    {
      heading_row: { color: 'green' },
      h3: { color: 'blue' },
      cell: { width: '50%' },
      question_cell: { color: 'red ' },
      answer_cell: { font_size: '100px' },
      first_row_cell: { padding_bottom: '20px' }
    }
  end

  before do
    allow(helper).to receive(:styles).and_return(test_styles)
  end

  describe '#inline_style_string' do
    let(:styles) { { font_weight: 'bold', font_size: '24px' } }

    it 'should genrate a style string from hash' do
      expect(helper.inline_style_string(styles)).to eql 'font-weight: bold; font-size: 24px;'
    end

    it 'should return empty string if not given a hash' do
      expect(helper.inline_style_string('not a hash')).to eql ''
    end
  end

  describe '#multiquestion_page?' do
    let(:single_q_page) { %w[answer] }
    let(:multi_q_page) { %w[answer1 answer2] }

    it 'is false for single question pages' do
      expect(helper.multiquestion_page?(single_q_page)).to be false
    end

    it 'is true when a multiquestion page' do
      expect(helper.multiquestion_page?(multi_q_page)).to be true
    end
  end

  describe '#answer_cell_styles' do
    let(:test_styles) do
      {
        cell: { width: '50%', padding_bottom: '10px' },
        answer_cell: { font_size: '100px' },
        first_row_cell: { padding_bottom: '20px' }
      }
    end

    it 'merges the cell and answer cell styles' do
      expect(helper.answer_cell_styles).to eql 'width: 50%; padding-bottom: 10px; font-size: 100px;'
    end

    it 'inlcudes the last row cell styles when first_row=true' do
      expect(helper.answer_cell_styles(first_row: true)).to eql 'width: 50%; padding-bottom: 20px; font-size: 100px;'
    end
  end

  describe '#question_cell_styles' do
    let(:test_styles) do
      {
        cell: { width: '50%', padding_bottom: '10px' },
        question_cell: { font_size: '100px' },
        first_row_cell: { padding_bottom: '20px' }
      }
    end

    it 'merges the cell and question cell styles' do
      expect(helper.question_cell_styles).to eql 'width: 50%; padding-bottom: 10px; font-size: 100px;'
    end

    it 'inlcudes the last row cell styles when first_row=true' do
      expect(helper.question_cell_styles(first_row: true)).to eql 'width: 50%; padding-bottom: 20px; font-size: 100px;'
    end
  end

  describe '#table_heading' do
    it 'should build the h2' do
      expect(helper.table_heading).to eql '<h2>Your answers</h2>'
    end
  end

  describe '#answer_cell' do
    it 'generates the table cell html with merged styles' do
      allow(helper).to receive(:answer_cell_styles).and_return('color: red; width: 50%;')
      expect(helper.answer_cell(content: 'answer')).to eql '<td style="color: red; width: 50%;">answer</td>'
    end
  end

  describe '#question_cell' do
    it 'generates the table cell html with merged styles' do
      allow(helper).to receive(:question_cell_styles).and_return('color: red; width: 50%;')

      expect(helper.question_cell(content: 'question')).to eql '<td style="color: red; width: 50%;">question</td>'
    end
  end

  describe '#answer_row' do
    let(:test_styles) do
      {
        cell: { width: '50%' },
        question_cell: { color: 'red' },
        answer_cell: { color: 'blue' },
        first_row_cell: { padding_bottom: '20px' }
      }
    end
    it 'generates the table row html with merged styles' do
      expect(helper.answer_row(question: 'question', answer: 'answer')).to eql '<tr><td style="width: 50%; color: red;">question</td><td style="width: 50%; color: blue;">answer</td></tr>'
    end

    it 'generates the last table row html with merged styles' do
      expect(helper.answer_row(question: 'question', answer: 'answer', first_row: true)).to eql '<tr><td style="width: 50%; color: red; padding-bottom: 20px;">question</td><td style="width: 50%; color: blue; padding-bottom: 20px;">answer</td></tr>'
    end
  end

  describe '#heading_row' do
    let(:test_styles) do
      {
        heading_row: { color: 'green' },
        h3: { color: 'blue' }
      }
    end
    it 'generates the heading row html' do
      expect(helper.heading_row('Heading')).to eql '<tr><td colspan="2" style="color: green;"><h3 style="color: blue;">Heading</h3></td></tr>'
    end
  end

  describe '#answers_table and #answers_html' do
    let(:test_styles) do
      {
        heading_row: { color: 'green' },
        h3: { color: 'blue' },
        cell: { color: 'red' },
        question_cell: { width: '50%' },
        answer_cell: { font_size: '100px' },
        first_row_cell: { padding_top: '20px' }
      }
    end

    let(:q1) { '<td style="color: red; width: 50%;">Question 1</td>' }
    let(:a1) { '<td style="color: red; font-size: 100px;">Answer 1</td>' }
    let(:q2) { '<td style="color: red; width: 50%;">Question 2</td>' }
    let(:a2) { '<td style="color: red; font-size: 100px;">Answer 2</td>' }
    let(:heading) { '<td colspan="2" style="color: green;"><h3 style="color: blue;">Page Heading</h3></td>' }
    let(:q3) { '<td style="color: red; width: 50%;">Question 3</td>' }
    let(:a3) { '<td style="color: red; font-size: 100px;">Answer 3</td>' }
    let(:q4) { '<td style="color: red; width: 50%;">Question 4</td>' }
    let(:a4) { '<td style="color: red; font-size: 100px;">Answer 4</td>' }
    let(:q5) { '<td style="color: red; width: 50%; padding-top: 20px;">Question 5</td>' }
    let(:a5) { '<td style="color: red; font-size: 100px; padding-top: 20px;">Answer 5</td>' }

    let(:table_html)  { "<table><tr>#{q1}#{a1}</tr><tr>#{q2}#{a2}</tr><tr>#{heading}</tr><tr>#{q3}#{a3}</tr><tr>#{q4}#{a4}</tr><tr>#{q5}#{a5}</tr></table>" }

    it 'generates the table html' do
      expect(helper.answers_table(pages)).to eql table_html
    end

    it 'generates the table html' do
      expect(helper.answers_html(pages)).to eql "<h2>Your answers</h2>#{table_html}"
    end
  end
end

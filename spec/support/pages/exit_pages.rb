class ExitPagesFixture < SitePrism::Page
  extend DataContentId

  set_url '/'
  element :start_button, :button, I18n.t('actions.start')
  element :page_b_field, :field, 'Page B'
  element :page_c_field, :field, 'Page C'
  element :page_i_field, :field, 'Page I'
  element :page_k_field, :field, 'Page K'
  element :page_l_field, :field, 'Page L'
  element :page_knowhere_field, :field, 'Road to knowhere'
  element :page_ghost_field, :field, 'Ghost town'
  element :continue_button, :button, I18n.t('actions.continue')
  element :item_3, :radio_button, 'Item 3'
  element :item_2, :radio_button, 'Item 2'
  element :back_link, :link, 'Back'
  elements :summary_list, '.govuk-summary-list__row'

  def check_your_answers_list
    summary_list.map do |element|
      question = element.find('.govuk-summary-list__key').text
      answer = element.find('.govuk-summary-list__value').text

      "#{question} #{answer}"
    end
  end
end

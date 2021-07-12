class BranchingFixture < SitePrism::Page
  extend DataContentId

  set_url '/'
  element :heading, 'h1'
  element :start_button, :button, 'Start'
  element :full_name_field, :field, 'Full name'
  element :star_wars_only_on_weekends, :radio_button, 'Only on weekends'
  element :star_wars_hell_no, :radio_button, 'Hell no!'
  element :apples, :radio_button, 'Apples'
  element :oranges, :radio_button, 'Oranges'
  element :pears, :radio_button, 'Pears'
  element :yes, :radio_button, 'Yes'
  element :beatles, :radio_button, 'Beatles'
  element :itunes, :radio_button, 'iTunes'
  element :moj, :radio_button, 'MoJ'
  element :others, :radio_button, 'Others'
  element :beef, :checkbox, 'Beef, cheese, tomato'
  element :chickens, :checkbox, 'Chicken, cheese, tomato'
  element :loki, :radio_button, 'Loki'
  element :falcon, :radio_button, 'The Falcon and the Winter Soldier'
  element :wandavision, :radio_button, 'WandaVision'
  element :back_link, :link, 'Back'
  element :continue_button, :button, 'Continue'
  elements :summary_list, '.govuk-summary-list__row'
  element :accept_and_send_button, :button, 'Accept and send application'
  element :confirmation_heading, '.govuk-panel__title'
  data_content_id :confirmation_lede, 'page[lede]'
  data_content_id :confirmation_body, 'page[body]'

  def check_your_answers_list
    summary_list.map do |element|
      question = element.find('.govuk-summary-list__key').text
      answer = element.find('.govuk-summary-list__value').text

      "#{question} #{answer}"
    end
  end
end

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
  element :continue_button, :button, 'Continue'
  element :accept_and_send_button, :button, 'Accept and send application'
end

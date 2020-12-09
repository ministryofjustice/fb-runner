class ComplainAboutTribunal < SitePrism::Page
  set_url '/'
  element :start_button, :button, 'Start'
  element :continue_button, :button, 'Continue'
  element :full_name_field, :field, 'Full name'
  element :email_field, :field, 'Your email address'
  element :back_link, :link, 'Back'
end

Rails.application.routes.draw do
  mount MetadataPresenter::Engine => "/"
end

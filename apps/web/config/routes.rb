# frozen_string_literal: true

namespace 'integrations' do
  namespace 'trello' do
    namespace 'connection' do

      get '',
        to: 'integrations/trello/connection#initialize',
        as: :trello_connection_initialize

      get 'callback',
        to: 'integrations/trello/connection#callback',
        as: :trello_connection_callback

      delete '',
        to: 'integrations/trello/connection#destroy',
        as: :trello_connection_destroy
    end
  end
end

root to: 'home#index'

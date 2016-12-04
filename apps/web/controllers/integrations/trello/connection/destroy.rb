# frozen_string_literal: true
module Web::Controllers
  module Integrations
    module Trello
      module Connection

        # Initialize Trello integration OAuth connection
        class Destroy
          include Web::Action
          include SharedMethods

          def call(_params)
            Trello.client(user: user).delete_token(user[:trello_access_token])
            Persistence::UserRepository.update_by_uuid(
              uuid: user[:uuid],
              trello_access_token: nil,
              trello_access_token_secret: nil,
              force_nil: true
            )
            redirect '/'
          end
        end
      end
    end
  end
end

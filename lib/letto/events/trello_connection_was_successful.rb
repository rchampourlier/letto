# frozen_string_literal: true
require_relative '../repositories/integration_repository'

# A domain event happening when a Trello connection is
# successful.
class TrelloConnectionWasSuccessful < Letto::Event
  param :user_uuid, Types::Strict::String
  param :access_token, Types::Strict::String
  param :access_token_secret, Types::Strict::String
  inject :integration_repository, proc { IntegrationRepository.new }
  inject :trello_client_class, Letto.dep(:trello_client_class)
  log_with Letto.dep(:logger)

  def perform_call
    create_or_update_trello_integration
  end

  private

  def create_or_update_trello_integration
    integration_repository.create_or_update(
      type: 'trello',
      user_uuid: user_uuid,
      data: {
        username: username,
        access_token: access_token,
        access_token_secret: access_token_secret
      }
    )
  end

  def username
    trello_client.username
  end

  def trello_client
    trello_client_class.new(access_token, access_token_secret)
  end
end

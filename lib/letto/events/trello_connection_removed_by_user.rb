# frozen_string_literal: true

# A domain event happening when the user removes the
# connection to its Trello account.
class TrelloConnectionRemovedByUser < Letto::Event
  param :user_uuid, Types::Strict::String
  inject :trello_client_class, Letto.dep(:trello_client_class)
  log_with Letto.dep(:logger)

  def perform_call
    @token, @secret = integrations.trello_tokens(user_uuid: user_uuid)
    delete_token_on_trello(@token)
    remove_trello_connection_from_user
  end

  private

  def delete_token_on_trello(token)
    trello_client.delete_token(token)
  end

  def remove_trello_connection_from_user
    users.update_by_id(
      id: user_uuid,
      trello_access_token: nil,
      trello_access_token_secret: nil,
      force_nil: true
    )
  end

  def integrations
    IntegrationRepository.new
  end

  def users
    UserRepository.new
  end

  def trello_client
    trello_client_class.new(@token, @secret)
  end
end

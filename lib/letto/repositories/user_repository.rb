# frozen_string_literal: true

# Repository for users (like usual).
class UserRepository < Hanami::Repository

  def update_by_id(id:, trello_access_token: nil, trello_access_token_secret: nil, force_nil: false)
    values = {
      trello_access_token: trello_access_token,
      trello_access_token_secret: trello_access_token_secret
    }
    values.reject! { |_, v| v.nil? } unless force_nil
    update_where({ id: id.to_s }, values)
  end
end

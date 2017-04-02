# frozen_string_literal: true
module Web::Controllers::Home

  # GET /
  class Index
    include Web::Action
    expose :user_uuid
    expose :trello_connected_username

    def initialize(
      integrations: IntegrationRepository.new
    )
      @integrations = integrations
    end

    def call(_params)
      @user_uuid = session[:user_uuid]
      @trello_connected_username = trello_username
    end

    private

    attr_reader :integrations

    def trello_username
      i = integrations.find_by_type_and_user_uuid('trello', @user_uuid)
      return nil if i.nil?
      i[:username]
    end
  end
end

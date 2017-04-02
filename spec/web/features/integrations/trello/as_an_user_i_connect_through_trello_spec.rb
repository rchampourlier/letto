# frozen_string_literal: true
require 'features_helper'

describe 'Integrations > Trello > As an user I connect through Trello' do

  it 'displays a link to connect through Trello' do
    visit('/')
    page.body.must_include('connect to Trello')
  end

  describe 'I click the Trello connection link on the homepage' do
    it 'redirection to authorize URL' do
      visit '/'
      click_link('connect to Trello')
      page.current_url.must_equal(
        'http://www.example.com/integrations/trello/connection/authorize_url?params=params'
      )
    end
  end

  # describe 'I return from a successful Trello authentication' do
  #
  #   it 'user is unknown' do
  #     it_will_fetch_an_oauth_access_token
  #     it_will_fetch_trello_username
  #     visit '/trello/connection/callback?oauth_token=012345&oauth_verifier=67890'
  #   end
  # end

  # Implementation

  # def it_will_fetch_an_oauth_access_token
  #   access_token = double(token: 'token', secret: 'secret')
  #   request_token = double(get_access_token: access_token)
  #   OAuth::RequestToken.expect(:new, request_token)
  #   OAuth::RequestToken.verify
  # end
  #
  # def it_will_fetch_trello_username
  #   trello_client = double(username: 'username')
  #   Letto::Integrations::Trello::Client.expect(:new, trello_client)
  #   Letto::Integrations::Trello::Client.verify
  # end
end

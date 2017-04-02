# frozen_string_literal: true
%i(get post).each do |verb|
  send(
    verb,
    '/webhooks/:user_uuid/:id/process',
    to: 'webhooks#process'
  )
end

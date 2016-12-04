# frozen_string_literal: true
ignore %r{^coverage/}
notification :terminal_notifier, activate: 'com.googlecode.iterm2'

group :server do
  guard :shotgun, server: 'puma', host: '0.0.0.0', port: '2300' do
    watch(/\.rb/)
  end
end

group :test do
  guard :minitest do
    watch(%r{^spec/(.*)_spec\.rb$})
    watch(%r{^lib/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
    watch(%r{^spec/spec_helper\.rb$}) { 'spec' }
    watch(%r{\.rb$})
  end
end

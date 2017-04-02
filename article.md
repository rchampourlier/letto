# Testing session in Hanami's action

It's a simple and short tip, but I couldn't find the solution easily in the documentation or anywhere else, so I figured it may help you there.

If you're using Hanami, you may be using sessions for your web interface. When you test an `Action`, you may want to inject a specific session in your test.

To do so, just use the `params` you inject into the action and set the `'rack.session'` value:

```ruby
describe Web::Controllers::YourAction do
  include Helpers

  let(:action) do
    Web::Controllers::YourAction.new
  end
  let(:params) do
    {
      'rack.session' => <HERE GOES YOUR SESSION!>
    }
  end
```

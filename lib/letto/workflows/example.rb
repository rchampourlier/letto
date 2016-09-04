# frozen_string_literal: true
workflow do

  # Option 1
  on_webhook do |payload, headers|
    return unless headers["APP"] == "trello"
    return unless payload["event"]["moved_card"]
    # do something
  end

  # Option 2
  on_webhook :trello, :moved_card do |payload, headers|
    # do something
  end
end

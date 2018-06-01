# frozen_string_literal: true

module DeviseHelpers
  class Capybara::Node::Simple
    # Undefined in Rails 5.0
    def readonly?
      !!self[:readonly]
      # false
      # synchronize { base.readonly? }
    end
  end
end
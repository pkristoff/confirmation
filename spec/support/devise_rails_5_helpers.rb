# frozen_string_literal: true

# DeviseRails5Helpers
#
module DeviseRails5Helpers
  # Simple
  #
  class Capybara::Node::Simple
    # Undefined in Rails 5.0
    #
    def readonly?
      self[:readonly] ? true : false
      # false
      # synchronize { base.readonly? }
    end
  end
end

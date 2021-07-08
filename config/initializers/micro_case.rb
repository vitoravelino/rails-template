# frozen_string_literal: true

require "operation"

Micro::Case.config do |config|
  # Use ActiveModel to auto-validate your use cases' attributes.
  config.enable_activemodel_validation = true

  # Use to enable/disable the `Micro::Case::Results#transitions`.
  config.enable_transitions = true
end

# frozen_string_literal: true

require 'factory_bot'
require 'webmock/rspec'
require 'tx_history'

FactoryBot.find_definitions

RSpec.configure do |config|
  # Use create, build, attributes_for, etc from FactoryBot.
  config.include FactoryBot::Syntax::Methods

  # Disable RSpec exposing methods globally on `Module` and `main`.
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

module Onboardings
  class FactoryJob < ApplicationJob
    queue_as :default

    def perform(organisation)
      Onboardings::Factory.create(organisation)
    end
  end
end

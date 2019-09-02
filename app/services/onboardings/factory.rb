module Onboardings
  class Factory
    def self.create(organisation)
      Onboarding.create(organisation: organisation)
    end
  end
end

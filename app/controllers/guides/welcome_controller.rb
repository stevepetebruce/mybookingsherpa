module Guides
  # Onboarding controller before Guides split into solo or company onboarding.
  class WelcomeController < ApplicationController
    layout "onboarding"
    before_action :authenticate_guide!

    def new; end
  end
end

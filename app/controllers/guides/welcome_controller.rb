module Guides
  class WelcomeController < ApplicationController
    before_action :authenticate_guide!

    def new; end
  end
end

module Guides
  class WelcomeController < ApplicationController
    before_action :authenticate_guide!
  end
end

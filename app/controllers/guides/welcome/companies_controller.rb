module Guides
  module Welcome
    class CompaniesController < ApplicationController
      before_action :authenticate_guide!

      def new; end
    end
  end
end

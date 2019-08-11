require "rails_helper"

RSpec.describe "Guides::RegistrationsController", type: :request do
  describe "#create POST /guides/" do
    def do_request(url: "/guides", params: {})
      post url, params: params
    end

    context "valid and successful" do
      let(:password) { Faker::Internet.password }
      let(:params) do
        {
          guide:
            {
              email: Faker::Internet.email,
              password: password,
              password_confirmation: password
            }
        }
      end

      it "creates a new guide and associated organisation" do
        do_request(params: params)

        expect(Guide.count).to eq 1
        expect(Guide.last.organisations).not_to be_empty
      end
    end
  end
end

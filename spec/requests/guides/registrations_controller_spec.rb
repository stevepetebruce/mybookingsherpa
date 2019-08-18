require "rails_helper"

RSpec.describe "Guides::RegistrationsController", type: :request do
  describe "#create POST /guides/" do
    def do_request(url: "/guides", params: {})
      post url, params: params
    end

    context "valid and successful" do
      let!(:email) { Faker::Internet.email }
      let(:guide) { Guide.find_by_email(email) }
      let(:password) { Faker::Internet.password }
      let(:params) do
        {
          guide:
            {
              email: email,
              password: password,
              password_confirmation: password
            }
        }
      end

      it "creates a new guide, associated organisation and onboarding model" do
        do_request(params: params)

        expect(Guide.count).to eq 1
        expect(guide.organisations).not_to be_empty
        expect(guide.organisations.first.onboarding).not_to be_nil
      end
    end
  end
end

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

      it "creates a new guide and associated organisation model" do
        do_request(params: params)

        expect(Guide.count).to eq 1
        expect(guide.organisations).not_to be_empty
      end

      it "redirects to guides/trips index" do
        do_request(params: params)

        expect(response.code).to eq "302"
        expect(response).to redirect_to authenticated_guide_url
      end
    end
  end
end

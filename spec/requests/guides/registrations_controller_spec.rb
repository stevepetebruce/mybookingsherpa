require "rails_helper"

RSpec.describe "Guides::RegistrationsController", type: :request do
  describe "#create POST /guides/" do
    def do_request(url: "/guides", params: {})
      post url, params: params
    end

    before do
      stub_request(:get, "http://api.ipstack.com/#{ip_address}?access_key=#{ENV.fetch("IP_STACK_API_KEY")}").
        to_return(status: 200, body: "#{file_fixture("ip_stack_api/gb_response.json").read}", headers: {})
    end

    before { FactoryBot.create(:plan, :regular) }

    context "valid and successful" do
      let!(:email) { Faker::Internet.email }
      let(:ip_address) { "127.0.0.1" }
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

      it "creates a new guide and associated organisation and subscription models" do
        do_request(params: params)

        expect(Guide.count).to eq 1
        expect(guide.organisations).not_to be_empty
        expect(guide.organisation_plan.name).to eq "regular"
      end

      it "redirects to guides/trips index" do
        do_request(params: params)

        expect(response.code).to eq "302"
        expect(response).to redirect_to authenticated_guide_url
      end
    end
  end
end

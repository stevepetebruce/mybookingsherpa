require "rails_helper"

RSpec.describe "Guides::Welcome::SolosController", type: :request do
  let!(:guide) { FactoryBot.create(:guide) }
  let!(:organisation) { FactoryBot.create(:organisation) }
  let!(:organisation_membership) do
    FactoryBot.create(:organisation_membership,
                      guide: guide,
                      organisation: organisation,
                      owner: true)
  end

  describe "#new" do
    include_examples "authentication"

    def do_request(url: "/guides/welcome/solos/new", params: {})
      get url, params: params
    end

    context "signed in" do
      before { sign_in(guide) }

      context "valid and successful" do
        it "should successfully render" do
          do_request

          expect(response).to be_successful
        end
      end
    end
  end

  describe "#create POST /guides/welcome/solos" do
    include_examples "authentication"

    def do_request(url: "/guides/welcome/solos", params: {})
      post url, params: params
    end

    context "signed in" do
      before { sign_in(guide) }

      context "valid and successful" do
        context "creating Stripe account" do
          let!(:params)  { { token_account: token_account } }
          let(:response_body) do
            "#{file_fixture("stripe_api/successful_individual_account.json").read}"
          end
          let!(:token_account) { "ct_#{Faker::Crypto.md5}" }

          before do
            stub_request(:post, "https://api.stripe.com/v1/accounts").
               with(body: {"account_token"=>token_account, "type"=>"custom"}).
               to_return(status: 200, body: response_body, headers: {})
          end

          it "should update the organisation's stripe_account_id" do
            do_request(params: params)

            expect(organisation.reload.stripe_account_id).not_to be_nil
          end

          it "should redirect_to the new_guides_welcome_solo page (to now create the bank account)" do
            do_request(params: params)

            expect(response.code).to eq "302"
            expect(response).to redirect_to new_guides_welcome_solo_url
          end
        end

        context "creating external/bank account" do
          let(:stripe_account_id) { organisation.stripe_account_id }
          let!(:organisation) { FactoryBot.create(:organisation, :with_stripe_account_id) }
          let!(:params) { { token_account: token_account } }
          let(:response_body) do
            "#{file_fixture("stripe_api/successful_external_account.json").read}"
          end
          let!(:token_account) { "btok_#{Faker::Crypto.md5}" }

          before do
            stub_request(:post, "https://api.stripe.com/v1/accounts/#{stripe_account_id}/external_accounts").
              with(body: {"external_account"=>"#{token_account}"}).
              to_return(status: 200, body: response_body, headers: {})
          end

          it "should update the organisation/ create the bank account... ???" do
            # TODO: need to create a stripe_api_response model for this call...
            # do_request(params: params)

            # expect(organisation.reload.stripe_account_id).not_to be_nil
          end

          it "should redirect_to the guides_trips_path" do
            do_request(params: params)

            expect(response.code).to eq "302"
            expect(response).to redirect_to guides_trips_url
          end
        end
      end
    end
  end
end

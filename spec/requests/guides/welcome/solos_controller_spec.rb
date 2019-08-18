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
      before do
        stub_request(:post, "https://api.stripe.com/v1/accounts").
          with(body: {"account_token"=>token_account, "type"=>"custom"}).
          to_return(status: 200, body: response_body, headers: {})

        sign_in(guide)
      end

      context "valid and successful" do
        let!(:params)  { { token_account: token_account } }
        let(:response_body) do
          "#{file_fixture("stripe_api/successful_individual_account.json").read}"
        end
        let!(:token_account) { "ct_#{Faker::Crypto.md5}" }

        it "should update the organisation's stripe_account_id" do
          do_request(params: params)

          expect(organisation.reload.stripe_account_id).not_to be_nil
        end

        it "should redirect_to the new_guides_welcome_bank_account page (to now create the bank account)" do
          do_request(params: params)

          expect(response.code).to eq "302"
          expect(response).to redirect_to new_guides_welcome_bank_account_url
        end
      end

      context "invalid and unsuccessful" do
        before do
          allow_any_instance_of(Organisation).to receive(:update).
            with(stripe_account_id: stripe_account_id).
            and_return(false)
        end

        let(:params)  { { token_account: token_account } }
        let(:response_body) do
          "#{file_fixture("stripe_api/successful_individual_account.json").read}"
        end
        let(:stripe_account_id) { "acct_1F6EFsL2bc7IXTSh" } # from: successful_individual_account.json
        let!(:token_account) { "ct_#{Faker::Crypto.md5}" }

        it "should redirect_to the back to the new_guides_welcome_solo_path" do
          do_request(params: params)

          expect(response.code).to eq "302"
          expect(response).to redirect_to new_guides_welcome_solo_url
        end
      end
    end
  end
end

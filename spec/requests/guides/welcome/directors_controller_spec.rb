require "rails_helper"

RSpec.describe "Guides::Welcome::DirectorsController", type: :request do
  let!(:guide) { FactoryBot.create(:guide) }
  let!(:organisation) { FactoryBot.create(:organisation, :with_stripe_account_id) }
  let!(:organisation_membership) do
    FactoryBot.create(:organisation_membership,
                      guide: guide,
                      organisation: organisation,
                      owner: true)
  end

  describe "#new" do
    include_examples "authentication"

    def do_request(url: "/guides/welcome/directors/new", params: {})
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

   describe "#create POST /guides/welcome/directors" do
    include_examples "authentication"

    def do_request(url: "/guides/welcome/directors", params: {})
      post url, params: params
    end

    context "signed in" do
      before do
        sign_in(guide)

        stub_request(:post, "https://api.stripe.com/v1/accounts/#{organisation.stripe_account_id}/persons").
          with(body: {"email"=>params[:email]}).
          to_return(status: 200, body: response_body, headers: {})
      end

      context "when not creating another director" do
        # TODO: replace these PII with a token from the person API
        # ref: https://stripe.com/docs/connect/account-tokens#form
        let!(:params)  { { email: Faker::Internet.email } }
        let(:response_body) do
          "#{file_fixture("stripe_api/successful_director.json").read}"
        end

        it "should create a director" do
          # TODO: actually need a way to persist the creation of a Stripe director in the app.
          expect(External::StripeApi::Person).
            to receive(:create).
            with(organisation.stripe_account_id,
                { email: params[:email] },
                organisation.on_trial?)

          do_request(params: params)
        end

        it "should redirect_to the new_guides_welcome_bank_account page (to now create the bank account)" do
          do_request(params: params)

          expect(response.code).to eq "302"
          expect(response).to redirect_to new_guides_welcome_bank_account_path
        end
      end

      context "when creating another director" do
        # TODO: replace these PII with a token from the person API
        # ref: https://stripe.com/docs/connect/account-tokens#form
        let!(:params)  { { email: Faker::Internet.email, add_another_director: true } }
        let(:response_body) do
          "#{file_fixture("stripe_api/successful_director.json").read}"
        end

        it "should create a director" do
          # TODO: actually need a way to persist the creation of a Stripe director in the app.
          expect(External::StripeApi::Person).
            to receive(:create).
            with(organisation.stripe_account_id,
                 { email: params[:email] },
                 organisation.on_trial?)

          do_request(params: params)
        end

        it "should redirect_to the new_guides_welcome_director_path page (to add another director)" do
          do_request(params: params)

          expect(response.code).to eq "302"
          expect(response).to redirect_to new_guides_welcome_director_path
        end
      end
    end
  end
end

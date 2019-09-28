require "rails_helper"

RSpec.describe "Guides::Welcome::CompanyPeopleController", type: :request do
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

    def do_request(url: "/guides/welcome/company_people/new", params: {})
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

   describe "#create POST /guides/welcome/company_people" do
    include_examples "authentication"

    def do_request(url: "/guides/welcome/company_people", params: {})
      post url, params: params
    end

    context "signed in" do
      before do
        sign_in(guide)

        stub_request(:post, "https://api.stripe.com/v1/accounts/#{organisation.stripe_account_id}/persons").
          to_return(status: 200, body: response_body, headers: {})
      end

      context "valid and successful" do
        context "when not creating another director" do
          let!(:params)  do
            {
              add_another_company_person: false,
              first_name: Faker::Name.name,
              last_name: Faker::Name.name,
              token_person: "person_#{Faker::Crypto.md5}"
            }
          end
          let(:response_body) do
            "#{file_fixture("stripe_api/successful_director.json").read}"
          end

          it "should create a director" do  
            expect{ do_request(params: params) }.to change { organisation.company_people.count }.from(0).to(1)

            expect(organisation.company_people.last.first_name).to eq params[:first_name]
            expect(organisation.company_people.last.last_name).to eq params[:last_name]
            expect(organisation.company_people.last.stripe_person_id).to eq "person_FqlOJaHYDG94Cl" # from: successful_director.json
          end

          it "should redirect_to the new_guides_welcome_bank_account page (to now create the bank account)" do
            do_request(params: params)

            expect(response.code).to eq "302"
            expect(response).to redirect_to new_guides_welcome_bank_account_path
          end
        end

        context "when creating another director" do
          let!(:params)  do 
            {
              add_another_company_person: true,
              first_name: Faker::Name.name,
              last_name: Faker::Name.name,
              token_person: "person_#{Faker::Crypto.md5}"
            }
          end
          let(:response_body) do
            "#{file_fixture("stripe_api/successful_director.json").read}"
          end

          it "should create a director" do
            expect{ do_request(params: params) }.to change { organisation.company_people.count }.from(0).to(1)

            expect(organisation.company_people.last.first_name).to eq params[:first_name]
            expect(organisation.company_people.last.last_name).to eq params[:last_name]
            expect(organisation.company_people.last.stripe_person_id).to eq "person_FqlOJaHYDG94Cl" # from: successful_director.json
          end

          it "should redirect_to the new_guides_welcome_company_person_path page (to add another director)" do
            do_request(params: params)

            expect(response.code).to eq "302"
            expect(response).to redirect_to new_guides_welcome_company_person_path
          end
        end
      end

      context "unsuccessful" do
        context "Stripe API throws an exception" do
          before do
            allow(Stripe::Account).to receive(:create_person).
              and_raise(Stripe::StripeError.
              new("Bad person", json_body: { error: { message: "There's a problem with this person" }}))
          end

          let!(:params)  do
            {
              add_another_company_person: false,
              first_name: Faker::Name.name,
              last_name: Faker::Name.name,
              token_person: "person_#{Faker::Crypto.md5}"
            }
          end
          let(:response_body) do
            "#{file_fixture("stripe_api/successful_director.json").read}" #TODO: need a real failed response json
          end

          it "should render the new_guides_welcome_company_person_path page with error message" do
            do_request(params: params)

            expect(response.code).to eq "200"
            expect(flash[:alert]).to eq("Problem creating person. Bad person")
          end
        end

        context "Validation error" do
          before do
            allow(CompanyPeople::Factory).to receive(:create).and_return(mock_company_person)
            allow(mock_company_person).to receive_message_chain(:errors, :full_messages, :to_sentence).
              and_return("Very bad person")
          end

          let(:mock_company_person) do 
            double("CompanyPerson", valid?: false)
          end

          let!(:params)  do
            {
              add_another_company_person: false,
              first_name: Faker::Name.name,
              last_name: Faker::Name.name,
              token_person: "person_#{Faker::Crypto.md5}"
            }
          end
          let(:response_body) do
            "#{file_fixture("stripe_api/successful_director.json").read}"
          end

          it "should render the new_guides_welcome_company_person_path page with error message" do
            do_request(params: params)

            expect(response.code).to eq "200"
            expect(flash[:alert]).to eq("Problem creating person. Very bad person")
          end
        end
      end
    end
  end
end

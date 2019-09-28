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

      context "when not creating another director" do
        let!(:params)  do
          {
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
  end
end
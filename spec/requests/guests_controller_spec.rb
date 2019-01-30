require "rails_helper"

RSpec.describe "GuestsController", type: :request do
  let(:resource_sign_in_path) { new_guest_session_path }

  describe "#edit GET /guests/:id/edit" do
    include_examples "authentication"

    let(:guest) { FactoryBot.create(:guest) }

    # TODO: Need to include tests for 1 time only token in the booking-to-guest email
    def do_request(url: "/guests/#{guest.id}/edit", params: {})
      get url, params: params
    end

    context "signed in" do
      before { sign_in(guest) }

      context "valid and successful" do
        it "should successfully render" do
          do_request

          expect(response).to be_successful
        end
      end
    end
  end

  describe "#show get /guests/:id" do
    include_examples "authentication"

    let!(:guest) { FactoryBot.create(:guest) }

    def do_request(url: "/guests/#{guest.id}", params: {})
      get url, params: params
    end

    context "signed in" do
      before { sign_in(guest) }

      context "valid and successful" do
        it "should successfully render" do
          do_request

          expect(response).to be_successful
        end

        context "another guest" do
          let!(:other_guest) { FactoryBot.create(:guest) }

          it "should not be visible to another guide" do
            sign_out(guest)
            sign_in(other_guest)

            do_request

            expect(response).to be_successful
            expect(response.body).to include(other_guest.name)
            expect(response.body).to_not include(guest.name)
            # And redirect_to?
          end
        end
      end
    end
  end

  describe "#update PATCH /guests/:id" do
    include_examples "authentication"

    let!(:guest) { FactoryBot.create(:guest) }

    def do_request(url: "/guests/#{guest.id}", params: {})
      patch url, params: params
    end

    context "signed in" do
      before { sign_in(guest) }

      context "valid and successful" do
        let!(:params) { 
          {
            guest: {
              address: Faker::Address.full_address,
              email: Faker::Internet.email,
              name: Faker::Name.name,
              phone_number: Faker::PhoneNumber.cell_phone
            }
          } 
        }

        it "should update the guest" do
          do_request(params: params)

          guest.reload

          expect(guest.address).to eq params[:guest][:address]
          expect(guest.email).to eq params[:guest][:email]
          expect(guest.name).to eq params[:guest][:name]
          expect(guest.phone_number).to eq params[:guest][:phone_number]

          # TODO: ** expect(guest.updated_by).to eq user
        end
      end

      context "invalid and unsuccessful" do
        # TODO: should we allow guests to update their emails this easily?
        let!(:params) { { guest: { email: nil } } }

        it "should update the guest" do
          do_request(params: params)

          expect(response.status).to eq(200)

          expect(guest.reload.email).to_not be_nil

          # TODO: ** expect(guest.updated_by).to eq user
        end
      end
    end
  end
end

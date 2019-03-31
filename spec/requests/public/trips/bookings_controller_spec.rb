require "rails_helper"

RSpec.describe "Public::Trips::BookingsController", type: :request do
  describe "#new GET /public/bookings/new" do
    let(:trip) { FactoryBot.create(:trip) }

    def do_request(url: "/public/trips/#{trip.id}/bookings/new", params: {})
      get url, params: params
    end

    it "should successfully render" do
      do_request

      expect(response).to be_successful
    end
  end

  describe "#create POST /public/trips/:trip_id/bookings" do
    let(:booking) { Booking.last }
    let!(:email) { Faker::Internet.email }
    let(:guest) { Guest.last }
    let!(:guide) { FactoryBot.create(:guide) }
    let!(:trip) { FactoryBot.create(:trip, guides: [guide]) }
    let(:organisation) { FactoryBot.create(:organisation) }
    let!(:organisation_membership) do
      FactoryBot.create(:organisation_membership,
                        guide: guide,
                        organisation: organisation,
                        owner: true)
    end
    let!(:params) do
      {
        booking:
        {
          address: Faker::Address.street_address,
          allergies: %i[dairy eggs nuts penicillin soya].sample,
          city: Faker::Address.city,
          country: Faker::Address.country_code,
          county: Faker::Address.state,
          date_of_birth: Faker::Date.birthday(18, 65),
          dietary_requirements: %i[other vegan vegetarian].sample,
          email: email,
          other_information: Faker::Lorem.sentence,
          name: Faker::Name.name,
          next_of_kin_name: Faker::Name.name,
          next_of_kin_phone_number: Faker::PhoneNumber.cell_phone,
          phone_number: Faker::PhoneNumber.cell_phone,
          post_code: Faker::Address.postcode
        },
        stripeToken: "tok_#{Faker::Crypto.md5}"
      }
    end
    let(:response_body) do
      "#{file_fixture("stripe_api/successful_charge.json").read}"
    end

    before do
      stub_request(:post, "https://api.stripe.com/v1/charges")
        .to_return(status: 200,
                   body: response_body,
                   headers: {})
    end

    def do_request(url: "/public/trips/#{trip.id}/bookings", params: {})
      post url, params: params
    end

    context "valid and successful" do
      let!(:email) { Faker::Internet.email }

      it 'should send out the new booking email to the guest and trip provider' do
        expect { do_request(params: params) }.to change { ActionMailer::Base.deliveries.count }.by(2)
        # TODO: mock these out with doubles and then test again
        # expect(GuestBookingMailer).to receive(:new)#.with(an_instance_of(Booking))
        # expect(GuideBookingMailer).to receive(:new)#.with(an_instance_of(Booking))
      end

      it "should create a new booking and payment record" do
        do_request(params: params)

        expect(trip.bookings).not_to be_empty
        expect(booking.payments).not_to be_empty
      end

      context "Use test queue_adapter" do
        before { ActiveJob::Base.queue_adapter = :test }
        after { ActiveJob::Base.queue_adapter = :inline }

        it "should call the UpdateBookingStatusJob" do
          expect { do_request(params: params) }.to have_enqueued_job(UpdateBookingStatusJob)
        end
      end

      context "a guest who does not yet exist" do
        it "should create the booking and the guest" do
          do_request(params: params)

          expect(Guest.count).to eq 1
          expect(Booking.count).to eq 1

          expect(trip.reload.bookings).to include booking
          expect(booking.guest).to eq guest
          expect(trip.guests).to include guest

          # Test all the params, email, name, etc
          params[:booking].each { |k, v| expect(booking.send(k)).to eq v.to_s }

          expect(response.code).to eq "302"
          expect(response).to redirect_to(edit_public_booking_path(booking))
        end
      end

      context "a guest who does already exist (via their email address)" do
        let!(:guest) { FactoryBot.create(:guest, email: email) }

        it "should create the booking but not the guest" do
          expect { do_request(params: params) }.not_to change { Guest.count }

          expect(trip.reload.bookings).to include booking
          expect(booking.guest).to eq guest
          expect(trip.guests).to include guest

          expect(response.code).to eq "302"
          expect(response).to redirect_to(edit_public_booking_path(booking))
        end
      end
    end

    context "unsuccesful" do
      # TODO: Stripe / Card issue
      context 'user enters an invalid email address' do
        let(:email) { Faker::Lorem.word }

        it 'should redirect back with error message' do
          do_request(params: params)

          expect(Guest.count).to eq 0
          expect(Booking.count).to eq 0

          expect(response.code).to eq "200"
          expect(response.body).to include("Email is invalid")
        end
      end
    end
  end

  describe "#edit GET /public/bookings/:id/edit" do
    def do_request(url: "/public/bookings/#{booking.id}/edit", params: {})
      get url, params: params
    end

    context "within timeout window of booking being created" do
      let(:booking) { FactoryBot.create(:booking, created_at: 10.minutes.ago) }

      it "should successfully render" do
        do_request

        expect(response).to be_successful
      end
    end

    context "timeout window of booking creation has expired" do
      let(:booking) { FactoryBot.create(:booking, created_at: 40.minutes.ago) }

      it "should redirect to the public trip new booking path" do
        do_request

        expect(response.code).to eq "302"
        expect(response).to redirect_to(new_public_trip_booking_path(booking.trip))
      end
    end
  end

  describe "#update PATCH /public/bookings/:id/update" do
    let(:params) { { booking: { email: email } } }

    def do_request(url: "/public/bookings/#{booking.id}", params: {})
      patch url, params: params
    end

    context "valid and successful" do
      let!(:email) { Faker::Internet.email }

      context "within timeout window of booking being created" do
        let(:booking) { FactoryBot.create(:booking, created_at: 10.minutes.ago) }

        it "should update the booking" do
          do_request(params: params)

          expect(response.code).to eq "302"
          expect(response).to redirect_to(public_booking_path(booking))

          expect(booking.reload.email).to eq email
        end
      end

      context "timeout window of booking creation has expired" do
        let(:booking) { FactoryBot.create(:booking, created_at: 40.minutes.ago) }

        it "should redirect to the public trip new booking path" do
          do_request

          expect(response.code).to eq "302"
          expect(response).to redirect_to(new_public_trip_booking_path(booking.trip))
        end
      end
    end
    context "invalid and unsuccessful" do
      let(:booking) { FactoryBot.create(:booking, created_at: 10.minutes.ago) }
      let(:email) { Faker::Lorem.word }

      it 'should redirect back with error message' do
        do_request(params: params)

        expect(response.code).to eq "200"
        expect(response.body).to include("Email is invalid")
      end
    end
  end

  describe "#show GET /public/bookings/:id/" do
    def do_request(url: "/public/bookings/#{booking.id}", params: {})
      get url, params: params
    end

    context "within timeout window of booking being created" do
      let(:booking) { FactoryBot.create(:booking, created_at: 10.minutes.ago) }

      it "should successfully render" do
        do_request

        expect(response).to be_successful
      end
    end

    context "timeout window of booking creation has expired" do
      let(:booking) { FactoryBot.create(:booking, created_at: 40.minutes.ago) }

      def do_request(url: "/public/bookings/#{booking.id}", params: {})
        get url, params: params
      end

      it "should redirect to the public trip new booking path" do
        do_request

        expect(response.code).to eq "302"
        expect(response).to redirect_to(new_public_trip_booking_path(booking.trip))
      end
    end
  end
end

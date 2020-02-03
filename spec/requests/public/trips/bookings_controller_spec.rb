require "rails_helper"

RSpec.describe "Public::Trips::BookingsController", type: :request do
  describe "#new GET /public/bookings/new" do
    let(:trip) { FactoryBot.create(:trip, organisation: organisation) }
    let(:organisation) { FactoryBot.create(:organisation, :not_on_trial, :on_regular_plan) }

    before do
      stub_request(:post, "https://api.stripe.com/v1/account_links").
        with(body: {
          "account"=>%r{acct_\d+},
          "collect"=>"currently_due",
          "failure_url"=>"http://www.example.com/guides/welcome/stripe_account_link_failure",
          "success_url"=>"http://www.example.com/guides/welcome/bank_accounts/new",
          "type"=>"custom_account_verification"}).
        to_return(status: 200, body: "#{file_fixture("stripe_api/successful_account_link.json").read}", headers: {})
      stub_request(:post, "https://api.stripe.com/v1/payment_intents").
        to_return(status: 200,
                  body: "#{file_fixture("stripe_api/successful_payment_intent.json").read}",
                  headers: {})
      stub_request(:post, "https://api.stripe.com/v1/payment_methods/pm_card_visa/attach").
        to_return(status: 200,
                  body: "#{file_fixture("stripe_api/successful_payment_method.json").read}",
                  headers: {})
      stub_request(:get, %r{https://api.stripe.com/v1/payment_intents/cus_\w+}).
        to_return(status: 200,
                  body: "#{file_fixture("stripe_api/successful_payment_intent.json").read}",
                  headers: {})

      FactoryBot.create(:onboarding, organisation: organisation)
    end

    def do_request(url: "/public/trips/#{trip.slug}/bookings/new", params: {})
      get url, params: params
    end

    it "should successfully render" do
      do_request

      expect(response).to be_successful
    end
  end

  describe "#create POST /public/trips/:trip_id/bookings" do
    context "organisation not on trial" do
      let(:booking) { Booking.last }
      let!(:email) { Faker::Internet.email }
      let(:guest) { Guest.last }
      let!(:guide) { FactoryBot.create(:guide) }
      let(:organisation) { FactoryBot.create(:organisation, :not_on_trial, :on_regular_plan) }
      let!(:params) do
        {
          booking:
          {
            country: Faker::Address.country_code,
            date_of_birth: Faker::Date.birthday(18, 65),
            email: email,
            other_information: Faker::Lorem.sentence,
            name: Faker::Name.name,
            next_of_kin_name: Faker::Name.name,
            next_of_kin_phone_number: Faker::PhoneNumber.cell_phone,
            phone_number: Faker::PhoneNumber.cell_phone
          },
          stripePaymentMethod: "pm_#{Faker::Crypto.md5}",
          payment_intent_id: "cus_#{Faker::Crypto.md5}"
        }
      end
      let!(:subdomain) { organisation.subdomain }
      let!(:trip) { FactoryBot.create(:trip, organisation: organisation) }

      before do
        stub_request(:post, "https://api.stripe.com/v1/charges").
          to_return(status: 200,
                    body: "#{file_fixture("stripe_api/successful_charge.json").read}",
                    headers: {})

        stub_request(:post, "https://api.stripe.com/v1/payment_intents").
          to_return(status: 200,
                    body: "#{file_fixture("stripe_api/successful_payment_intent.json").read}",
                    headers: {})

        stub_request(:post, "https://api.stripe.com/v1/customers").
          to_return(status: 200,
                    body: "#{file_fixture("stripe_api/successful_customer.json").read}",
                    headers: {})

        stub_request(:post, "https://api.stripe.com/v1/account_links").
          with(body: {
            "account"=>%r{acct_\d+},
            "collect"=>"currently_due",
            "failure_url"=>"http://www.example.com/guides/welcome/stripe_account_link_failure",
            "success_url"=>"http://www.example.com/guides/welcome/bank_accounts/new",
            "type"=>"custom_account_verification"}).
          to_return(status: 200, body: "#{file_fixture("stripe_api/successful_account_link.json").read}", headers: {})
        stub_request(:post, "https://api.stripe.com/v1/payment_methods/pm_card_visa/attach").
          to_return(status: 200, body: "#{file_fixture("stripe_api/successful_payment_method.json").read}", headers: {})
        stub_request(:get, %r{https://api.stripe.com/v1/payment_intents/cus_\w+}).
          to_return(status: 200, body: "#{file_fixture("stripe_api/successful_payment_intent.json").read}", headers: {})
      end

      def do_request(url: "/public/trips/#{trip.slug}/bookings", params: {})
        post url, params: params
      end

      context "valid and successful" do
        let!(:email) { Faker::Internet.email }

        it "should not send out the new booking email to the guest and trip provider - this happens in the stripe payment_intent webhook" do
          expect { do_request(params: params) }.not_to change { ActionMailer::Base.deliveries.count }
        end

        it "should create a new booking and payment record" do
          do_request(params: params)

          expect(trip.bookings).not_to be_empty
          expect(booking.payments).not_to be_empty
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
            edit_public_booking_url(booking, subdomain: subdomain)
          end
        end

        context "a guest who does already exist (via their email address)" do
          let!(:pre_existing_guest) { FactoryBot.create(:guest, email: email) }
          let(:expected_redirect_url) do
            url_for(controller: "bookings",
                    action: "edit",
                    id: booking.id,
                    subdomain: booking.organisation_subdomain_or_www,
                    tld_length: 1,
                  )
          end

          it "should create the booking but not the guest" do
            expect { do_request(params: params) }.not_to change { Guest.count }

            expect(trip.reload.bookings).to include booking
            expect(booking.guest).to eq pre_existing_guest
            expect(trip.guests).to include pre_existing_guest

            expect(response.code).to eq "302"
            expect(response).to redirect_to expected_redirect_url
          end
        end
      end

      context "unsuccesful" do
        context "user enters an invalid email address" do
          let(:email) { Faker::Lorem.word }

          it "should redirect back with error message" do
            # pending 'sca work - come back to...'
            # do_request(params: params)

            # expect(Guest.count).to eq 0
            # expect(Booking.count).to eq 0

            # expect(response.code).to eq "200"
            # expect(response.body).to include("Please enter a valid email")
          end
        end

        # TODO: need to look at what Stripe errors may come back from the PaymentIntents API
        # and cover them here....

        context "user enters an card that attaches to the customer but the charge fails" do
          before do
            allow(Stripe::Charge).to receive(:create).
              and_raise(Stripe::CardError.new("Card declined", nil, json_body: { error: { message: "Card declined" }}))
          end

          it "should redirect back with error message" do
            do_request(params: params)

            pending 'SCA: need to test this when webhook comes in with this error'
            expect(response.code).to eq "200"
            expect(flash[:alert]).to eq("Payment unsuccessful. Card declined")
          end

          it "should create a guest and a booking with a stripe_customer_id and stripe_payment_method_id" do
            do_request(params: params)

            expect(Guest.count).to eq 1
            expect(Booking.count).to eq 1
            expect(Booking.last.stripe_customer_id).to_not be_nil
            expect(Booking.last.stripe_payment_method_id).to_not be_nil
          end
        end

        context "user experiences rate limiting of the Stripe API" do
          before do
            allow(Stripe::Charge).to receive(:create).
              and_raise(Stripe::RateLimitError.new)
          end

          it "should redirect back with error message" do
            do_request(params: params)

            pending 'SCA: need to test this when webhook comes in with this error'
            expect(response.code).to eq "200"
            expect(flash[:alert]).to eq("Payment unsuccessful. RateLimitError. Please try again or contact Guide for help.")
          end

          it "should create a guest and a booking with a stripe_customer_id and stripe_payment_method_id" do
            # Should it? What if the call to create the customer failed too?
            do_request(params: params)

            expect(Guest.count).to eq 1
            expect(Booking.count).to eq 1
            expect(Booking.last.stripe_customer_id).to_not be_nil
            expect(Booking.last.stripe_payment_method_id).to_not be_nil
          end
        end

        context "invalid parameter sent to Stripe API" do
          before do
            allow(Stripe::Charge).to receive(:create).
              and_raise(Stripe::InvalidRequestError.new("Invalid request", nil))
          end

          it "should redirect back with error message" do
            do_request(params: params)

            pending 'SCA: need to test this when webhook comes in with this error'
            expect(response.code).to eq "200"
            expect(flash[:alert]).to eq("Payment unsuccessful.  Invalid request. Please try again or contact Guide for help.")
          end

          it "should still create a guest and a booking with a stripe_customer_id" do
            # Should it? What if the call to create the customer failed too?
            do_request(params: params)

            expect(Guest.count).to eq 1
            expect(Booking.count).to eq 1
            expect(Booking.last.stripe_customer_id).to_not be_nil
          end
        end

        context "authentication error" do
          before do
            allow(Stripe::Charge).to receive(:create).
              and_raise(Stripe::AuthenticationError.new)
          end

          it "should redirect back with error message" do
            do_request(params: params)

            pending 'SCA: need to test this when webhook comes in with this error'
            expect(response.code).to eq "200"
            expect(flash[:alert]).to eq("Payment unsuccessful. AuthenticationError. Please try again or contact Guide for help.")
          end

          it "should still create a booking and a guest with a stripe_customer_id" do
            # Should it? What if the call to create the customer failed too?
            do_request(params: params)

            expect(Guest.count).to eq 1
            expect(Booking.count).to eq 1
            expect(Booking.last.stripe_customer_id).to_not be_nil
            expect(Booking.last.stripe_payment_method_id).to_not be_nil
          end
        end

        context "API connection error" do
          before do
            allow(Stripe::Charge).to receive(:create).
              and_raise(Stripe::APIConnectionError.new)
          end

          it "should redirect back with error message" do
            do_request(params: params)

            pending 'SCA: need to test this when webhook comes in with this error'
            expect(response.code).to eq "200"
            expect(flash[:alert]).to eq("Payment unsuccessful. APIConnectionError. Please try again or contact Guide for help.")
          end

          it "should still create a guest and a booking with a stripe_customer_id" do
            # Should it? What if the call to create the customer failed too?
            do_request(params: params)

            expect(Guest.count).to eq 1
            expect(Booking.count).to eq 1
            expect(Booking.last.stripe_customer_id).to_not be_nil
            expect(Booking.last.stripe_payment_method_id).to_not be_nil
          end
        end

        context "General Stripe API error" do
          before do
            allow(Stripe::Charge).to receive(:create).
              and_raise(Stripe::StripeError.new)
          end

          it "should redirect back with error message" do
            do_request(params: params)

            pending 'SCA: need to test this when webhook comes in with this error'
            expect(response.code).to eq "200"
            expect(flash[:alert]).to eq("Payment unsuccessful. StripeError. Please try again or contact Guide for help.")
          end

          it "should still create a guest and a booking with a stripe_customer_id" do
            # Should it? What if the call to create the customer failed too?
            do_request(params: params)

            expect(Guest.count).to eq 1
            expect(Booking.count).to eq 1
            expect(Booking.last.stripe_customer_id).to_not be_nil
            expect(Booking.last.stripe_payment_method_id).to_not be_nil
          end
        end
      end
    end

    context "organisation on trial" do
      let(:booking) { Booking.last }
      let!(:email) { Faker::Internet.email }
      let(:guest) { Guest.last }
      let!(:guide) { FactoryBot.create(:guide) }
      let(:organisation) { FactoryBot.create(:organisation, :on_regular_plan) }
      let!(:params) do
        {
          booking:
          {
            country: Faker::Address.country_code,
            date_of_birth: Faker::Date.birthday(18, 65),
            email: email,
            other_information: Faker::Lorem.sentence,
            name: Faker::Name.name,
            next_of_kin_name: Faker::Name.name,
            next_of_kin_phone_number: Faker::PhoneNumber.cell_phone,
            phone_number: Faker::PhoneNumber.cell_phone
          },
          stripePaymentMethod: "pm_#{Faker::Crypto.md5}",
          payment_intent_id: "cus_#{Faker::Crypto.md5}"
        }
      end
      let!(:subdomain) { organisation.subdomain }
      let!(:trip) { FactoryBot.create(:trip, organisation: organisation) }

      before do
        stub_request(:post, "https://api.stripe.com/v1/charges").
          to_return(status: 200,
                    body: "#{file_fixture("stripe_api/successful_charge.json").read}",
                    headers: {})

        stub_request(:post, "https://api.stripe.com/v1/payment_intents").
          to_return(status: 200,
                    body: "#{file_fixture("stripe_api/successful_payment_intent.json").read}")

        stub_request(:post, "https://api.stripe.com/v1/customers").
          to_return(status: 200,
                    body: "#{file_fixture("stripe_api/successful_customer.json").read}",
                    headers: {})
        stub_request(:post, "https://api.stripe.com/v1/payment_methods/pm_card_visa/attach").
          to_return(status: 200,
                    body: "#{file_fixture("stripe_api/successful_payment_method.json").read}",
                    headers: {})
        stub_request(:get, %r{https://api.stripe.com/v1/payment_intents/cus_\w+}).
          to_return(status: 200, body: "#{file_fixture("stripe_api/successful_payment_intent.json").read}", headers: {})
      end

      def do_request(url: "/public/trips/#{trip.slug}/bookings", params: {})
        post url, params: params
      end

      context "valid and successful" do
        let!(:email) { Faker::Internet.email }

        it "should send out the new booking email to the guest and trip provider" do
          expect { do_request(params: params) }.to change { ActionMailer::Base.deliveries.count }.by(2)
        end

        it "should create a new booking and payment record" do
          do_request(params: params)

          expect(trip.bookings).not_to be_empty
          expect(booking.payments).not_to be_empty
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
            expect(response).to redirect_to(edit_public_booking_url(booking, subdomain: subdomain))
          end
        end

        context "a guest who does already exist (via their email address)" do
          let!(:pre_existing_guest) { FactoryBot.create(:guest, email: email) }
          let(:expected_redirect_url) do
            url_for(controller: "bookings",
                    action: "edit",
                    id: booking.id,
                    subdomain: booking.organisation_subdomain_or_www,
                    tld_length: 1,
                  )
          end

          it "should create the booking but not the guest" do
            expect { do_request(params: params) }.not_to change { Guest.count }

            expect(trip.reload.bookings).to include booking
            expect(booking.guest).to eq pre_existing_guest
            expect(trip.guests).to include pre_existing_guest

            expect(response.code).to eq "302"
            expect(response).to redirect_to expected_redirect_url
          end
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
      let(:subdomain) { booking.organisation_subdomain_or_www }

      it "should redirect to the public trip new booking path" do
        do_request

        expect(response.code).to eq "302"
        expect(response).to redirect_to new_public_trip_booking_url(booking.trip_slug, subdomain: subdomain)
      end
    end
  end

  describe "#update PATCH /public/bookings/:id/update" do
    let!(:allergies) { Allergy::POSSIBLE_ALLERGIES.sample(rand(1..3)).sort }
    let!(:dietary_requirements) { DietaryRequirement::POSSIBLE_DIETARY_REQUIREMENTS.sample(rand(1..3)).sort }
    let(:params) { { booking: { allergies: allergies, dietary_requirements: dietary_requirements, email: email } } }

    def do_request(url: "/public/bookings/#{booking.id}", params: {})
      patch url, params: params
    end

    before do
      stub_request(:post, "https://api.stripe.com/v1/account_links").
        with(body: {
          "account"=>%r{acct_\d+},
          "collect"=>"currently_due",
          "failure_url"=>"http://www.example.com/guides/welcome/stripe_account_link_failure",
          "success_url"=>"http://www.example.com/guides/welcome/bank_accounts/new",
          "type"=>"custom_account_verification"}).
        to_return(status: 200, body: "#{file_fixture("stripe_api/successful_account_link.json").read}", headers: {})
    end

    context "valid and successful" do
      let!(:email) { Faker::Internet.email }

      context "within timeout window of booking being created" do
        let!(:booking) { FactoryBot.create(:booking, created_at: 10.minutes.ago) }
        let!(:subdomain) { booking.organisation_subdomain_or_www }

        context "with no allergies or dietary_requirements" do
          let(:params) { { booking: { email: email } } }

          it "should update the booking" do
            do_request(params: params)

            expect(response.code).to eq "302"
            expect(response).to redirect_to public_booking_url(booking, subdomain: subdomain)

            expect(booking.reload.email).to eq email
          end
        end

        context "with allergies and dietary_requirements" do
          let!(:allergies) { Allergy::POSSIBLE_ALLERGIES.sample(rand(1..3)).sort }
          let!(:dietary_requirements) { DietaryRequirement::POSSIBLE_DIETARY_REQUIREMENTS.sample(rand(1..3)).sort }
          let(:params) { { booking: { allergies: allergies, dietary_requirements: dietary_requirements, email: email } } }

          it "should create the booking's allergies" do
            do_request(params: params)

            expect(booking.reload.allergies.count).to eq allergies.count
            expect(booking.allergies.map(&:name).sort).to eq allergies
          end

          it "should create the booking's dietary_requirements" do
            do_request(params: params)

            expect(booking.reload.dietary_requirements.count).to eq dietary_requirements.count
            expect(booking.dietary_requirements.map(&:name).sort).to eq dietary_requirements
          end
        end

        context "when other_information is passed in as a blank string" do
          let(:params) { { booking: { other_information: "" } } }

          it "should not update the booking's other_information field" do
            do_request(params: params)

            expect(booking.reload.other_information).to be_nil
          end
        end
      end

      context "timeout window of booking creation has expired" do
        let(:booking) { FactoryBot.create(:booking, created_at: 40.minutes.ago) }
        let!(:subdomain) { booking.organisation_subdomain_or_www }

        it "should redirect to the public trip new booking path" do
          do_request

          expect(response.code).to eq "302"
          expect(response).to redirect_to(new_public_trip_booking_url(booking.trip_slug, subdomain: subdomain))
        end
      end
    end
    context "invalid and unsuccessful" do
      let!(:booking) { FactoryBot.create(:booking, created_at: 10.minutes.ago) }
      let(:email) { Faker::Lorem.word }

      before { FactoryBot.create(:onboarding, organisation: booking.organisation) }

      it "should redirect back with error message" do
        do_request(params: params)

        expect(response.code).to eq "200"
        expect(response.body).to include("Please enter a valid email")
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
      let!(:subdomain) { booking.organisation_subdomain_or_www }


      def do_request(url: "/public/bookings/#{booking.id}", params: {})
        get url, params: params
      end

      it "should redirect to the public trip new booking path" do
        do_request

        expect(response.code).to eq "302"
        expect(response).to redirect_to(new_public_trip_booking_url(booking.trip_slug, subdomain: subdomain))
      end
    end
  end
end

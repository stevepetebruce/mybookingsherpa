# Guest can log in via a one time only log in token
# sent on new bookings
RSpec.shared_examples "one_time_login_token" do
  let(:one_time_login_token_param_key) { "#{GuestsController::OBFUSCATED_ONE_TIME_LOGIN_TOKEN_PARAM_NAME}" }
  let(:onetime_only_login_params) do
    {
      email: guest.email,
      "#{one_time_login_token_param_key}": guest.one_time_login_token
    }
  end

  context "not signed in" do
    context "no one_time_login_token present" do
      it "should redirect the guest to sign in" do
        do_request

        expect(response).to redirect_to(new_guest_session_path)
      end
    end

    context "invalid one_time_login_token (ie: could of been used before)" do
      it "should redirect the guest to sign in" do
        do_request(params: params.merge(email: guest.email, one_time_login_token: Faker::Lorem.word))

        expect(response).to redirect_to(new_guest_session_path)
      end
    end

    context "valid one_time_login_token present" do
      let!(:booking) { FactoryBot.create(:booking, :all_fields_complete, guest: guest) }

      it "should log the guest in" do
        do_request(params: params.merge(onetime_only_login_params))

        expect(response).to be_successful
      end

      it "should reset the one_time_login_token" do
        expect { do_request(params: params.merge(onetime_only_login_params)) }.
          to change { guest.reload.one_time_login_token }
      end

      it "should update the guest's booking fields" do
        pending "Need to fix the enums (ex: dietary_requirements_booking) when copying data"
        do_request(params: params.merge(onetime_only_login_params))

        expect(guest.reload.address_booking).to eq booking.address
      end
    end
  end
end

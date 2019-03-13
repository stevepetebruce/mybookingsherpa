RSpec.shared_examples "one_time_login_token" do
  let(:one_time_login_token_param_key) { "#{GuestsController::OBFUSCATED_ONE_TIME_LOGIN_TOKEN_PARAM_NAME}" }

  context "not signed in" do
    context "no one_time_login_token present" do
      it "should redirect the guest to sign in" do
        do_request

        expect(response).to redirect_to(new_guest_session_path)
      end
    end

    context "invalid one_time_login_token (ie: could of been used before)" do
      it "should redirect the guest to sign in" do
        do_request(params: params.merge(one_time_login_token: Faker::Lorem.word))

        expect(response).to redirect_to(new_guest_session_path)
      end
    end

    context "valid one_time_login_token present" do
      it "should log the guest in" do
        do_request(params: params.merge(email: guest.email,
                                        "#{one_time_login_token_param_key}": guest.one_time_login_token))

        expect(response).to be_successful
      end

      it "should reset the one_time_login_token" do
        expect do do_request(params: params.merge(email: guest.email,
                                                  "#{one_time_login_token_param_key}": guest.one_time_login_token))
        end.to change { guest.reload.one_time_login_token }
      end
    end
  end
end

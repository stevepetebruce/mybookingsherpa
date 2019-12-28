require "rails_helper"

RSpec.describe "SessionsController", type: :request do
  context "signing in" do
    context "guests" do
      describe "#create POST /guests/sign_in" do
        let!(:guest) { FactoryBot.create(:guest) }
        let!(:params) { { guest: { email: guest.email, password: guest.password } } }

        def do_request(url: "/guests/sign_in", params: {})
          post url, params: params
        end

        it "redirects to the guest page" do
          # pending "have removed these routes for launch Jan 2020"
          # do_request(params: params)

          # expect(response.code).to eq "302"
          # expect(response).to redirect_to(guests_trips_path)
        end
      end
    end

    context "guides" do
      describe "#create POST /guides/sign_in" do
        let!(:guide) { FactoryBot.create(:guide) }
        let!(:params) { { guide: { email: guide.email, password: guide.password } } }

        def do_request(url: "/guides/sign_in", params: {})
          post url, params: params
        end

        it "redirects to the guest page" do
          # pending "have removed these routes for launch Jan 2020"
          # do_request(params: params)

          # expect(response.code).to eq "302"
          # expect(response).to redirect_to(guides_trips_path)
        end
      end
    end
  end

  context "signing out" do
    context "guests" do
      describe "#destroy DELETE /guests/sign_out" do
        let!(:guest) { FactoryBot.create(:guest) }

        before { sign_in(guest) }

        def do_request(url: "/guests/sign_out", params: {})
          delete url, params: params
        end

        it "redirects to the guest page" do
          # pending "have removed these routes for launch Jan 2020"
          # do_request

          # expect(response.code).to eq "302"
          # expect(response).to redirect_to(new_guest_session_path)
        end
      end
    end

    context "guides" do
      describe "#destroy DELETE /guides/sign_out" do
        let!(:guide) { FactoryBot.create(:guide) }

        before { sign_in(guide) }

        def do_request(url: "/guides/sign_out", params: {})
          delete url, params: params
        end

        it "redirects to the guest page" do
          # pending "have removed these routes for launch Jan 2020"
          # do_request

          # expect(response.code).to eq "302"
          # expect(response).to redirect_to(new_guide_session_path)
        end
      end
    end
  end
end

require 'rails_helper'

RSpec.describe 'Public::GuestsController', type: :request do
  context 'within timeout window of guest being created' do
    let(:guest) { FactoryBot.create(:guest, created_at: 10.minutes.ago)}

    describe '#show GET /public/guests/:id' do
      def do_request(url: "/public/guests/#{guest.id}", params: {})
        get url, params: params
      end

      it 'should successfully render' do
        do_request

        expect(response).to be_successful
      end
    end

    describe '#edit GET /public/guests/:id/edit' do
      def do_request(url: "/public/guests/#{guest.id}/edit", params: {})
        get url, params: params
      end

      it 'should successfully render' do
        do_request

        expect(response).to be_successful
      end
    end

    describe '#update PATCH /public/guests/:id' do
      let!(:email) { Faker::Internet.email }
      let!(:guest) { FactoryBot.create(:guest) }
      # TODO: Do we want to allow public editing of guests' email?
      let(:params) { { guest: { email: email } } }

      def do_request(url: "/public/guests/#{guest.id}", params: {})
        patch url, params: params
      end

      it 'should update the guest' do
        do_request(params: params)

        expect(response.code).to eq '302'
        expect(response).to redirect_to(public_guest_path(guest))

        expect(guest.reload.email).to eq email
      end
    end
  end

  context 'timeout window of guest creation has expired' do
    let(:guest) { FactoryBot.create(:guest, created_at: 40.minutes.ago)}

    describe '#show GET /public/guests/:id' do
      def do_request(url: "/public/guests/#{guest.id}", params: {})
        get url, params: params
      end

      it 'should redirect to root path' do # TODO: redirect to public/trip#show path when built in.
        do_request

        expect(response.code).to eq '302'
        expect(response).to redirect_to(root_path)
      end
    end

    describe '#edit GET /public/guests/:id/edit' do
      def do_request(url: "/public/guests/#{guest.id}/edit", params: {})
        get url, params: params
      end

      it 'should redirect to root path' do # TODO: redirect to public/trip#show path when built in.
        do_request

        expect(response.code).to eq '302'
        expect(response).to redirect_to(root_path)
      end
    end

    describe '#update PATCH /public/guests/:id' do # TODO: redirect to public/trip#show path when built in.
      def do_request(url: "/public/guests/#{guest.id}", params: {})
        patch url, params: params
      end

      it 'should redirect to root path' do
        do_request

        expect(response.code).to eq '302'
        expect(response).to redirect_to(root_path)
      end
    end
  end
end

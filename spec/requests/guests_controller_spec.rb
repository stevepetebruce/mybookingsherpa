require 'rails_helper'

RSpec.describe 'GuestsController', type: :request do
  # TODO: ** implement created_by and updated_by and test them here

  describe '#create POST /guests' do
    # TODO: this is overridden by Devise::RegistrationsController#create
    # Need to make other route to allow a guide to add/ create a guest...
    # include_examples 'authentication'

    # TODO: need to test the sign up path rather than directly creating a guest
    # Only guests can create themselves? By signing up?

    def do_request(url: "/guests", params: {})
      post url, params: params
    end

    context 'valid and successful' do
      let(:guest) { Guest.last }
      let!(:params) do
        { guest: 
          {
            address: Faker::Address.full_address,
            email: Faker::Internet.email,
            name: Faker::Name.name,
            phone_number: Faker::PhoneNumber.cell_phone
          }
        }
      end

      it 'should create a new guest' do
        pending 'Need to think about how guests are created: when they sign up to a trip, and when a guide adds them to a trip, etc'
        expect { do_request(params: params) }.to change { Guest.count }.by(1)

        expect(response.code).to eq '302'
        expect(response).to redirect_to(guest_path(guest))

        expect(guest.address).to eq params[:guest][:address]
        expect(guest.email).to eq params[:guest][:email]
        expect(guest.name).to eq params[:guest][:name]
        expect(guest.phone_number).to eq params[:guest][:phone_number]

        # TODO: ** expect(guest.created_by).to eq user
        # TODO: ** expect(guest.updated_by).to eq user
      end
    end
  end

  describe '#edit GET /guests/:id/edit' do
    include_examples 'authentication'

    # TODO: who can do this? A user can update their own details - need to scope this to current_user
    # A guide can edit a guests' organisation_membership but not the user details (email, etc).
    # Need to test that a guest / guide / public access - can not access this guest's edit page.
    # Need to scope so that only the current logged in user can update their own details.
    # Revisit when Devise is installed

    let(:guest) { FactoryBot.create(:guest) }

    def do_request(url: "/guests/#{guest.id}/edit", params: {})
      get url, params: params
    end

    context 'valid and successful' do
      it 'should successfully render' do
        pending 'Need to make sure that only a signed in user can edit their OWN details, and that a guide can edit a users guest_trip details, etc'
        do_request

        expect(response).to be_successful
      end
    end
  end

  describe '#index get /guests' do
    include_examples 'authentication'

    # TODO: need to scope this to an organisation?
    # Test that current_user is organsation owner and they can only access their own organisation's users
    # All other cases, redirect to home page
    # Revisit when Devise is installed
    def do_request(url: "/guests/", params: {})
      get url, params: params
    end

    context 'valid and successful' do
      it 'should successfully render' do
        pending 'see notes above'
        do_request

        expect(response).to be_successful
      end
    end
  end

  describe '#new get /guests/new' do
    include_examples 'authentication'

    # TODO: This is the sign up page? Or is the creation of new guests done in the background
    # when a guest clicks on a guide's link to join a trip?
    # Revisit when Devise is installed
    def do_request(url: "//guests/new", params: {})
      get url, params: params
    end

    it 'should successfully render' do
      pending 'see notes above'
      do_request

      expect(response).to be_successful
    end
  end

  describe '#show get /guests/:id' do
    include_examples 'authentication'

    # TODO: Need to scope this to either a user, who can view ONLY their own details
    # OR: a guide who has a guest associated with their organisation
    # Revisit when Devise is installed
    let(:guest) { FactoryBot.create(:guest) }

    def do_request(url: "/guests/#{guest.id}", params: {})
      get url, params: params
    end

    context 'valid and successful' do
      it 'should successfully render' do
        pending 'see notes above'
        do_request

        expect(response).to be_successful
      end
    end
  end

  describe '#update PATCH /guests/:id' do
    include_examples 'authentication'

    # Need to scope so that only the current logged in user can update their own details.
    # An organisation owner, can update a user's other details, via their organisation_membership
    # Revist when Devise is installed
    let!(:guest) { FactoryBot.create(:guest) }

    def do_request(url: "/guests/#{guest.id}", params: {})
      patch url, params: params
    end

    context 'valid and successful' do
      let(:params) { 
        {
          guest: {
            address: Faker::Address.full_address,
            email: Faker::Internet.email,
            name: Faker::Name.name,
            phone_number: Faker::PhoneNumber.cell_phone
          }
        } 
      }

      it 'should update the guest' do
        pending 'See notes above'
        do_request(params: params)

        guest.reload

        expect(guest.address).to eq params[:guest][:address]
        expect(guest.email).to eq params[:guest][:email]
        expect(guest.name).to eq params[:guest][:name]
        expect(guest.phone_number).to eq params[:guest][:phone_number]

        # TODO: ** expect(guest.updated_by).to eq user
      end
    end
  end
end

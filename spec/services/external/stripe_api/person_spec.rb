require "rails_helper"

RSpec.describe External::StripeApi::Person, type: :model do
  describe "#create" do
    subject(:create) { described_class.create(stripe_account_id, person_params, use_test_api) }

    # TODO: replace this with Stripe person token
    let!(:person_params) { { email: Faker::Internet.email } }
    let!(:stripe_account_id) { "acct_#{Faker::Bank.account_number(16)}" }
    let(:use_test_api) { [true, false].sample }

    context "successfully creates person (director/owner)" do
      it "should call Stripe::Account#create_person" do
        expect(Stripe::Account).to receive(:create_person).with(stripe_account_id, person_params)

        create
      end
    end
  end
end

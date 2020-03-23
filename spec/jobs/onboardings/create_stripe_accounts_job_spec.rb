require "rails_helper"

RSpec.describe Onboardings::CreateStripeAccountsJob, type: :job do
  before { ActiveJob::Base.queue_adapter = :inline }

  describe "#perform_later" do
    subject(:perform_later) { described_class.perform_later(organisation) }

    let!(:guide) { FactoryBot.create(:guide) }
    let!(:organisation) { FactoryBot.create(:organisation, :with_country_specific_data) }
    let(:response_body) do
      "#{file_fixture("stripe_api/successful_individual_account.json").read}"
    end

    before do
      OrganisationMembership.create(organisation: organisation, guide: guide, owner: true)

      stub_request(:post, "https://api.stripe.com/v1/accounts").
        with(body: {
          "country"=>organisation.country_code.upcase,
          "email"=>guide.email,
          "requested_capabilities"=>["card_payments", "transfers"],
          "type"=>"custom" }).
        to_return(status: 200, body: response_body, headers: {})

      stub_request(:post, "https://api.stripe.com/v1/accounts").
         with(body: {
          "country"=>organisation.country_code,
          "email"=>guide.email,
          "requested_capabilities"=>["card_payments", "transfers"],
          "type"=>"custom"}).
         to_return(status: 200, body: response_body, headers: {})
    end

    context "valid and successful" do
      it "should update the organisation's stripe_account_id_test" do
        perform_later

        expect(organisation.reload.stripe_account_id_test).to_not be_nil
      end
    end
  end
end

require "rails_helper"

RSpec.describe Organisations::CreateTestStripeAccountJob, type: :job do
  before { ActiveJob::Base.queue_adapter = :inline }

  describe "#perform_later" do
    subject(:perform_later) { described_class.perform_later(organisation) }

    let!(:guide) { FactoryBot.create(:guide) }
    let!(:organisation) { FactoryBot.create(:organisation) }
    let(:response_body) do
      "#{file_fixture("stripe_api/successful_individual_account.json").read}"
    end

    before do
      OrganisationMembership.create(organisation: organisation, guide: guide, owner: true)

      stub_request(:post, "https://api.stripe.com/v1/accounts").
        with(body: {"country"=>"FR", "email"=>guide.email, "type"=>"custom"}).
        to_return(status: 200, body: response_body, headers: {})
    end

    context "valid and successful" do
      it "should update the organisation's stripe_account_id" do
        perform_later

        expect(organisation.reload.stripe_account_id).to_not be_nil
      end
    end
  end
end

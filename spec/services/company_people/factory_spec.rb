require "rails_helper"

RSpec.describe CompanyPeople::Factory, type: :model do
  describe "#create" do
    subject(:create) { described_class.create(email,
                                             first_name,
                                             last_name,
                                             organisation,
                                             relationship,
                                             stripe_person_id) }

    let!(:email) { Faker::Internet.email }
    let!(:first_name) { Faker::Name.name }
    let!(:last_name) { Faker::Name.name }
    let!(:organisation) { FactoryBot.create(:organisation) }
    let!(:relationship) { %w[director owner].sample }
    let!(:stripe_person_id) { "person_#{Faker::Crypto.md5}" }

    context "valid and successful" do
      it "should create a new company_person associated with the organisation" do
        expect { create }.to change { organisation.company_people.count }.from(0).to(1)
      end
    end
  end
end

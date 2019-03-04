require "rails_helper"

RSpec.describe Guest, type: :model do
  describe "associations" do
    it { should have_many(:bookings) }
    it { should have_many(:trips).through(:bookings) }
  end

  describe "callbacks" do
    let(:guest) { FactoryBot.create(:guest) }

    it "should call #set_updatable_fields after_update" do
      expect(guest).to receive(:set_updatable_fields)

      guest.update(email: Faker::Internet.email)
    end
  end

  describe "#set_updatable_fields" do
    subject { described_class.new(guest).update_fields }

    context "booking fields" do
      context "with no booking fields with values" do
        let(:guest) { FactoryBot.create(:guest, :all_updatable_fields_empty) }

        it "should not update the canonical fields" do
          expect { guest.send(:set_updatable_fields) }.to_not change { guest.attributes }
        end
      end

      context "with booking fields that have values" do
        let(:guest) { FactoryBot.create(:guest, :all_booking_fields_complete, :all_updatable_fields_empty) }

        it "should update the canonical fields from the booking fields" do
          guest.send(:set_updatable_fields)

          Guest::UPDATABLE_FIELDS.each do |field|
            expect(guest.send("#{field}")).to eq guest.send("#{field}_booking")
          end
        end
      end

      context "with canonical fields with pre-existing values" do
        let(:guest) { FactoryBot.create(:guest, :all_override_fields_complete) }

        it "should not update the canonical fields" do
          expect { guest.send(:set_updatable_fields) }.to_not change { guest.attributes }
        end
      end
    end

    context "override fields" do
      context "with no override fields with values" do
        let(:guest) { FactoryBot.create(:guest) }

        it "should clear the canonical fields" do
          expect { guest.send(:set_updatable_fields) }.to_not change { guest.attributes }
        end
      end

      context "with override fields that have values" do
        let(:guest) { FactoryBot.create(:guest, :all_override_fields_complete) }

        it "should update the canonical fields from the override fields" do
          guest.send(:set_updatable_fields)

          Guest::UPDATABLE_FIELDS.each do |field|
            expect(guest.send("#{field}")).to eq guest.send("#{field}_override")
          end
        end
      end
    end

    context "booking and override fields" do
      let(:guest) { FactoryBot.create(:guest, :all_override_fields_complete, :all_booking_fields_complete) }

      it "should let the override fields take precedence over the booking fields" do
        guest.send(:set_updatable_fields)

        Guest::UPDATABLE_FIELDS.each do |field|
          expect(guest.send("#{field}")).to eq guest.send("#{field}_override")
        end
      end
    end
  end

  describe "validations" do
    context "email" do
      it { should allow_value(Faker::Internet.email).for(:email) }
      it { should_not allow_values(Faker::Lorem.word, Faker::PhoneNumber.cell_phone ).for(:email) }
      it { should validate_presence_of(:email) }
      it { should validate_uniqueness_of(:email).ignoring_case_sensitivity }
    end
    context "name" do
      it { should_not allow_value("<SQL INJECTION>").for(:name) }
      it { should allow_value(Faker::Lorem.word).for(:name) }
    end
    context "phone_number" do
      it { should allow_value(Faker::PhoneNumber.cell_phone).for(:phone_number) }
      it { should_not allow_value(Faker::Lorem.word).for(:phone_number) }
    end
  end

  it { should define_enum_for(:allergies).with(%i[dairy eggs nuts penicillin soya]) }
  it { should define_enum_for(:dietary_requirements).with(%i[other vegan vegetarian]) }
end

require "rails_helper"

RSpec.describe Guest, type: :model do
  describe "associations" do
    it { should have_many(:bookings) }
    it { should have_many(:trips).through(:bookings) }
  end

  describe "callbacks" do
    let!(:guest) { FactoryBot.build(:guest) }

    it "should call #enums_none_to_nil" do
      expect(guest).to receive(:enums_none_to_nil)

      guest.save
    end

    it "should call #set_updatable_fields after_update" do
      expect(guest).to receive(:set_updatable_fields)

      guest.update(email: Faker::Internet.email)
    end

    it "should call #set_one_time_login_token" do
      expect(guest).to receive(:set_one_time_login_token)

      guest.save
    end

    it "should call #update_bookings_status" do
      expect(guest).to receive(:update_bookings_status)

      guest.save
    end
  end

  describe "#enums_none_to_nil" do
    subject { described_class.new(guest).enums_none_to_nil }

    context "a guest with allergies and dietary_requirements set to 'none'" do
      let(:guest) { FactoryBot.build(:guest, allergies: "none", dietary_requirements: "none") }

      it "should set the fields to nil" do
        expect { guest.send(:enums_none_to_nil) }.to change { guest.allergies }.from('none').to(nil)
      end
    end

    context "a guest with allergies and dietary_requirements values" do
      let!(:allergies) { %i[dairy eggs nuts soya].sample }
      let!(:dietary_requirements) { %i[other vegan vegetarian].sample }
      let(:guest) { FactoryBot.build(:guest, allergies: allergies, dietary_requirements: dietary_requirements) }

      it "should not change the value of the fields" do
        guest.send(:enums_none_to_nil)

        expect(guest.allergies).to eq(allergies.to_s)
        expect(guest.dietary_requirements).to eq(dietary_requirements.to_s)
      end
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

  describe "#most_recent_booking" do
    subject { described_class.new(guest).most_recent_booking }

    context "a guest with multiple bookings" do
      let!(:guest) { FactoryBot.build(:guest) }
      let!(:new_booking) { FactoryBot.create(:booking, created_at: Time.zone.now, guest: guest) }
      let!(:old_booking) { FactoryBot.create(:booking, created_at: 2.days.ago, guest: guest) }

      it "should return the most recently created booking" do
        expect(guest.most_recent_booking).to eq(new_booking)
      end
    end

    context "a guest with no bookings" do
      let!(:guest) { FactoryBot.build(:guest) }

      it "should return nil" do
        expect(guest.most_recent_booking).to be_nil
      end
    end
  end

  describe "validations" do
    context "email" do
      it { should allow_value(Faker::Internet.email).for(:email) }
      it { should allow_value("alan.donohoe@mybookingsherpa.com").for(:email) }
      it { should_not allow_values(Faker::Lorem.word, Faker::PhoneNumber.cell_phone ).for(:email) }
      it { should validate_presence_of(:email) }
      it { should validate_uniqueness_of(:email).ignoring_case_sensitivity }
    end
    context "country" do
      it { should allow_value(Faker::Address.country_code).for(:county) }
      it { should_not allow_value(Faker::Lorem.word).for(:email) }
    end
    context "name" do
      it { should_not allow_value("<SQL INJECTION>").for(:name) }
      it { should allow_value(Faker::Lorem.word).for(:name) }
    end
    context "next_of_kin_name" do
      it { should allow_value(Faker::Name.name).for(:next_of_kin_name) }
      it { should_not allow_value("<SQL INJECTION;>").for(:next_of_kin_name) }
    end
    context "next_of_kin_phone_number" do
      it { should allow_value(Faker::PhoneNumber.cell_phone).for(:next_of_kin_phone_number) }
      it { should_not allow_value( Faker::Name.name).for(:next_of_kin_phone_number) }
    end
    context "phone_number" do
      it { should allow_value(Faker::PhoneNumber.cell_phone).for(:phone_number) }
      it { should_not allow_value(Faker::Lorem.word).for(:phone_number) }
    end
  end

  it { should define_enum_for(:allergies).with(%i[none other dairy eggs nuts soya]) }
  it { should define_enum_for(:dietary_requirements).with(%i[none other vegan vegetarian]) }
end

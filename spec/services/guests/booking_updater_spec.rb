require "rails_helper"

RSpec.describe Guests::BookingUpdater, type: :model do
  describe "#copy_booking_values" do
    subject { described_class.new(guest).copy_booking_values(booking) }

    context "a guest with no overriden values set" do
      let!(:booking) { FactoryBot.build(:booking, :all_fields_complete) }
      let!(:guest) { FactoryBot.create(:guest) }
      let(:non_enum_updatable_fields) do
        updatable_fields.reject do |field|
          %i[allergies dietary_requirements].include?(field)
        end
      end
      let(:updatable_fields) do
        %i[address allergies city country county date_of_birth
           dietary_requirements medical_conditions name
           next_of_kin_name next_of_kin_phone_number phone_number
           post_code].freeze
      end

      it "should update the guest's 'field'_booking and 'field' values" do
        subject

        non_enum_updatable_fields.each do |field|
          expect(guest.send("#{field}_booking")).to eq booking.send(field)
        end
      end
    end
  end
end

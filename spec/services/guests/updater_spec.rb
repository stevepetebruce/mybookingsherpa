require "rails_helper"

RSpec.describe Guests::Updater, type: :model do
  describe "#update_fields" do
    subject { described_class.new(guest).update_fields }

    context "booking fields" do
      context "with no cannonical fields with values" do
        context "with no booking fields with values" do
          let(:guest) { FactoryBot.create(:guest, :all_updatable_fields_empty) }

          it "should not update the cannonical fields" do
            expect { guest.send(:set_updatable_fields) }.to_not change { guest.attributes }
          end
        end

        context "with booking fields that have values" do
          let(:guest) do
            FactoryBot.create(:guest,
                              :all_booking_fields_complete,
                              :all_updatable_fields_empty)
          end

          it "should update the cannonical fields from the booking fields" do
            guest.send(:set_updatable_fields)

            Guests::Updater::UPDATABLE_FIELDS.each do |field|
              expect(guest.send("#{field}")).to eq guest.send("#{field}_booking")
            end
          end
        end
      end

      context "with cannonical fields with pre-existing values" do
        let(:guest) { FactoryBot.create(:guest, :all_updatable_fields_complete) }

        it "should not update the cannonical fields" do
          expect { guest.send(:set_updatable_fields) }.to_not change { guest.attributes }
        end
      end
    end

    context "override fields" do
      context "with no override fields with values" do
        let(:guest) { FactoryBot.create(:guest) }

        it "should not update the cannonical fields" do
          expect { guest.send(:set_updatable_fields) }.to_not change { guest.attributes }
        end
      end

      context "with override fields that have values" do
        let(:guest) { FactoryBot.create(:guest, :all_override_fields_complete) }

        it "should update the cannonical fields from the override fields" do
          guest.send(:set_updatable_fields)

          Guests::Updater::UPDATABLE_FIELDS.each do |field|
            expect(guest.send("#{field}")).to eq guest.send("#{field}_override")
          end
        end
      end
    end

    context "booking and override fields" do
      let(:guest) { FactoryBot.create(:guest, :all_override_fields_complete, :all_booking_fields_complete) }

      it "should let the override fields take precedence over the booking fields" do
        guest.send(:set_updatable_fields)

        Guests::Updater::UPDATABLE_FIELDS.each do |field|
          expect(guest.send("#{field}")).to eq guest.send("#{field}_override")
        end
      end
    end
  end
end



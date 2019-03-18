require "rails_helper"

RSpec.describe Bookings::StatusUpdater, type: :model do
  describe "#new_status" do
    subject(:new_status) { described_class.new(booking).new_status }

    context "a booking that has not made any payment" do
      # This would be the case where the Guide has manually added a guest
      context "a booking that has only added partial personal details" do
        let(:booking) { FactoryBot.create(:booking, :basic_fields_complete, guest: guest) }

        context "a guest that has no other details added" do
          let(:guest) { FactoryBot.create(:guest) }

          it "should set the booking's status to yellow" do
            expect(new_status).to eq :yellow
          end
        end

        context "a guest that has full details added (previously)" do
          let(:guest) { FactoryBot.create(:guest, :all_override_fields_complete) }

          it "should set the booking's status to yellow" do
            expect(new_status).to eq :yellow
          end
        end
      end

      context "a booking that has added full personal details" do
        let(:booking) { FactoryBot.create(:booking, :all_fields_complete, guest: guest) }

        context "a guest that has no other details added" do
          let(:guest) { FactoryBot.create(:guest) }

          it "should set the booking's status to yellow" do
            expect(new_status).to eq :yellow
          end
        end

        context "a guest that has full details added (previously)" do
          let(:guest) { FactoryBot.create(:guest, :all_override_fields_complete) }

          it "should set the booking's status to yellow" do
            expect(new_status).to eq :yellow
          end
        end
      end
    end

    context "a booking that has paid the deposit for the trip" do
      context "a booking that has only added partial personal details" do
        let(:booking) { FactoryBot.create(:booking, :basic_fields_complete, guest: guest) }
        let(:deposit_amount) { booking.full_cost * 0.5 }
        let!(:payment) { FactoryBot.create(:payment, amount: deposit_amount, booking: booking) }

        context "a guest that has no other details added" do
          let(:guest) { FactoryBot.create(:guest) }

          it "should set the booking's status to yellow" do
            expect(new_status).to eq :yellow
          end
        end

        context "a guest that has full details added (previously)" do
          let(:guest) { FactoryBot.create(:guest, :all_override_fields_complete) }

          it "should set the booking's status to yellow" do
            expect(new_status).to eq :yellow
          end
        end
      end

      context "a booking that has added full personal details" do
        let(:booking) { FactoryBot.create(:booking, :all_fields_complete, guest: guest) }

        context "a guest that has no other details added" do
          let(:guest) { FactoryBot.create(:guest) }

          it "should set the booking's status to yellow" do
            expect(new_status).to eq :yellow
          end
        end

        context "a guest that has full details added (previously)" do
          let(:guest) { FactoryBot.create(:guest, :all_override_fields_complete) }

          it "should set the booking's status to yellow" do
            expect(new_status).to eq :yellow
          end
        end
      end
    end

    context "a booking that has paid the full cost of the trip" do
      context "a booking that has only added partial personal details" do
        let(:booking) { FactoryBot.create(:booking, :basic_fields_complete, guest: guest) }
        let!(:payment) { FactoryBot.create(:payment, amount: booking.full_cost, booking: booking) }

        context "a guest that has no other details added" do
          let(:guest) { FactoryBot.create(:guest) }

          it "should set the booking's status to yellow" do
            expect(new_status).to eq :yellow
          end
        end

        context "a guest that has full details added (previously)" do
          let(:guest) { FactoryBot.create(:guest, :all_override_fields_complete) }

          it "should set the booking's status to green" do
            expect(new_status).to eq :green
          end
        end
      end

      context "a booking that has added full personal details" do
        let(:booking) { FactoryBot.create(:booking, :all_fields_complete, guest: guest) }
        let!(:payment) { FactoryBot.create(:payment, amount: booking.full_cost, booking: booking) }

        context "a guest that has no other details added" do
          let(:guest) { FactoryBot.create(:guest) }

          it "should set the booking's status to green" do
            expect(new_status).to eq :green
          end
        end

        context "a guest that has full details added (previously)" do
          let(:guest) { FactoryBot.create(:guest, :all_override_fields_complete) }

          it "should set the booking's status to green" do
            expect(new_status).to eq :green
          end
        end
      end
    end
  end
end

require "rails_helper"

RSpec.describe Bookings::Status, type: :model do
  describe "#allergies?" do
    subject(:allergies?) { described_class.new(booking).allergies? }

    let!(:allergy) { %i[dairy eggs nuts penicillin soya].sample }

    context "a booking that has no allergies" do
      let(:booking) { FactoryBot.create(:booking, guest: guest) }

      context "a guest associated with the booking that has no allergies" do
        let(:guest) { FactoryBot.create(:guest) }

        it { expect(allergies?).to eq false }
      end

      context "a guest associated with the booking that has allergies" do
        let!(:guest) do
          FactoryBot.create(:guest, email: 'foo@blah.com',
                            allergies: allergy,
                            allergies_override: allergy)
        end

        it { expect(allergies?).to eq true }
      end
    end

    context "a booking that has allergies" do
      let(:booking) { FactoryBot.create(:booking, guest: guest, allergies: allergy) }

      context "a guest associated with the booking that has no allergies" do
        let(:guest) { FactoryBot.create(:guest) }

        it { expect(allergies?).to eq true }
      end

      context "a guest associated with the booking that has allergies" do
        let(:guest) { FactoryBot.create(:guest, allergies: allergy) }

        it { expect(allergies?).to eq true }
      end
    end
  end

  describe "#dietary_requirements?" do
    subject(:dietary_requirements?) { described_class.new(booking).dietary_requirements? }

    let!(:dietary_requirement) { %i[other vegan vegetarian].sample }

    context "a booking that has no dietary_requirements" do
      let(:booking) { FactoryBot.create(:booking, guest: guest) }

      context "a guest associated with the booking that has no dietary_requirements" do
        let(:guest) { FactoryBot.create(:guest) }

        it { expect(dietary_requirements?).to eq false }
      end

      context "a guest associated with the booking that has dietary_requirements" do
        let!(:guest) do
          FactoryBot.create(:guest, email: 'foo@blah.com',
                            dietary_requirements: dietary_requirement,
                            dietary_requirements_override: dietary_requirement)
        end

        it { expect(dietary_requirements?).to eq true }
      end
    end

    context "a booking that has dietary_requirements" do
      let(:booking) { FactoryBot.create(:booking, guest: guest, dietary_requirements: dietary_requirement) }

      context "a guest associated with the booking that has no dietary_requirements" do
        let(:guest) { FactoryBot.create(:guest) }

        it { expect(dietary_requirements?).to eq true }
      end

      context "a guest associated with the booking that has dietary_requirements" do
        let(:guest) { FactoryBot.create(:guest, dietary_requirements: dietary_requirement) }

        it { expect(dietary_requirements?).to eq true }
      end
    end
  end

  describe "#medical_conditions?" do
    subject(:medical_conditions?) { described_class.new(booking).medical_conditions? }

    let!(:medical_condition) { %w[asthma vertigo arthritis].sample }

    context "a booking that has no medical_conditions" do
      let(:booking) { FactoryBot.create(:booking, guest: guest) }

      context "a guest associated with the booking that has no medical_conditions" do
        let(:guest) { FactoryBot.create(:guest) }

        it { expect(medical_conditions?).to eq false }
      end

      context "a guest associated with the booking that has medical_conditions" do
        let!(:guest) do
          FactoryBot.create(:guest, email: 'foo@blah.com',
                            medical_conditions: medical_condition,
                            medical_conditions_override: medical_condition)
        end

        it { expect(medical_conditions?).to eq true }
      end
    end

    context "a booking that has medical_conditions" do
      let(:booking) { FactoryBot.create(:booking, guest: guest, medical_conditions: medical_condition) }

      context "a guest associated with the booking that has no medical_conditions" do
        let(:guest) { FactoryBot.create(:guest) }

        it { expect(medical_conditions?).to eq true }
      end

      context "a guest associated with the booking that has medical_conditions" do
        let(:guest) { FactoryBot.create(:guest, medical_conditions: medical_condition) }

        it { expect(medical_conditions?).to eq true }
      end
    end
  end

  describe "#new_status" do
    subject(:new_status) { described_class.new(booking).new_status }

    context "a booking that has not made any payment" do
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

  describe "#payment_required?" do
    subject(:payment_required?) { described_class.new(booking).payment_required? }

    let(:booking) { FactoryBot.create(:booking) }

    context "a booking that has not made any payment" do
      it { expect(payment_required?).to eq true }
    end

    context "a booking that has paid the deposit for the trip" do
      let(:deposit_amount) { booking.full_cost * 0.5 }
      let!(:payment) { FactoryBot.create(:payment, amount: deposit_amount, booking: booking) }

      it { expect(payment_required?).to eq true }
    end

    context "a booking that has paid the full cost of the trip" do
      let!(:payment) { FactoryBot.create(:payment, amount: booking.full_cost, booking: booking) }

      it { expect(payment_required?).to eq false }
    end

    context "a booking that has paid above full cost of the trip, ie: bought extras" do
      let(:eatras_amount) { rand(300...500) }
      let!(:payment) { FactoryBot.create(:payment, amount: booking.full_cost + eatras_amount, booking: booking) }

      it { expect(payment_required?).to eq false }
    end
  end
end

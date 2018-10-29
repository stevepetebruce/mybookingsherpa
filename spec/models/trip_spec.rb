require 'rails_helper'

RSpec.describe Trip, type: :model do
  describe 'associations' do
    it { should have_many(:bookings) }
    it { should have_many(:guests).through(:bookings) }
    it { should have_and_belong_to_many(:guides) }
  end

  describe 'validations' do
    describe 'name' do
      it { should_not allow_value('<SQL INJECTION>').for(:name) }
      it { should allow_value(Faker::Lorem.word).for(:name) }
      # TODO: check uniqueness to organisation scope
    end

    describe 'minimum_number_of_guests' do
      it { should validate_numericality_of(:minimum_number_of_guests).only_integer }
    end

    describe 'maximum_number_of_guests' do
      it { should validate_numericality_of(:maximum_number_of_guests).only_integer }
    end

    # TODO: when know format of date string we're sending back and also test that
    describe 'dates' do
      subject { trip.valid? }

      let(:trip) { FactoryBot.build(:trip, start_date: start_date, end_date: end_date) }

      context 'valid' do
        context 'start_date is before end_date' do
          let(:start_date) { Date.today }
          let(:end_date) { Faker::Date.between(2.days.from_now, 10.days.from_now) }

          it { should be true }
        end
      end

      context 'invalid' do
        context 'start_date is after end_date' do
          let(:start_date) { Faker::Date.between(2.days.from_now, 10.days.from_now) }
          let(:end_date) { Date.today }

          it { should be false }
        end
      end
    end
  end
end

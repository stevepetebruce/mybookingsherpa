# Tracks all new Guides' onboarding events
class Onboarding < ApplicationRecord
  belongs_to :organisation
  after_save :update_complete

  def track_event(event, additional_info = nil)
    events << {
      name: event,
      additional_info: additional_info,
      created_at: Time.zone.now
    }.reject { |_k, v| v.blank? }

    save
  end

  def find_event(event_name)
    events.select { |event| event["name"] == event_name }&.first
  end

  def just_completed_set_up?
    complete? &&
      find_event("trial_ended").presence["created_at"] > 5.minutes.ago
  end

  def solo_founder?
    events.select { |event| event["name"] == "new_solo_account_chosen" }.any?
  end

  private

  def bank_and_stripe_accounts_complete?
    bank_account_complete? && stripe_account_complete?
  end

  def update_complete
    update_columns(complete: bank_and_stripe_accounts_complete?)
  end
end

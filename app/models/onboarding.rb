# Tracks all new Guides' onboarding events
class Onboarding < ApplicationRecord
  belongs_to :organisation

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

  def solo_founder?
    events.select { |event| event["name"] == "new_solo_account_chosen" }.any?
  end
end

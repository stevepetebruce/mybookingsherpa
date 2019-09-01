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
end

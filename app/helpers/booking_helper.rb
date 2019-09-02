module BookingHelper
  def trial_example_full_name_or_nil(booking)
    # TODO: make this geo sensitive...
    booking.organisation_on_trial? ? "Emmanuel Macron" : nil
  end

  def trial_example_email_or_nil(booking)
    # TODO: make this geo sensitive...
    booking.organisation_on_trial? ? "e.macron@gmail.com" : nil
  end

  def trial_example_card_number_or_nil(booking)
    booking.organisation_on_trial? ? "4242424242424242" : nil
  end
end
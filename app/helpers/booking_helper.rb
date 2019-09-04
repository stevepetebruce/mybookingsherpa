module BookingHelper
  def trial_example_country(_booking)
    # TODO: If the booking.organisation.onboarding.country_codes were set previously...
    # based on the data in the JS geo... then we could use this here to choose
    # correct country, person, etc... Just have a hash with a key being the
    # country code, then underneath, everything.
    ["France", "FR"]
  end

  def trial_example_dob_or_nil(booking)
    booking.organisation_on_trial? ? "1977-12-21" : nil
  end

  def trial_example_email_or_nil(booking)
    # TODO: make this geo sensitive...
    booking.organisation_on_trial? ? "e.macron@gmail.com" : nil
  end

  def trial_example_full_name_or_nil(booking)
    # TODO: make this geo sensitive...
    booking.organisation_on_trial? ? "Emmanuel Macron" : nil
  end

  def trial_example_ice_name_or_nil(booking)
    # TODO: make this geo sensitive...
    booking.organisation_on_trial? ? "Brigitte Macron" : nil
  end

  def trial_example_ice_phone_or_nil(booking)
    # TODO: make this geo sensitive...
    # when we move geo over to ruby can just return country code here if not in trial
    booking.organisation_on_trial? ? "+330123456789" : nil
  end

  def trial_example_phone_or_nil(booking)
    # TODO: make this geo sensitive...
    # when we move geo over to ruby can just return country code here if not in trial
    booking.organisation_on_trial? ? "+330123456789" : nil
  end
end

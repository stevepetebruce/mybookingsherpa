module StripeTestHelper
  def stripe_event_signature(event_json, secret)
    timestamp = Time.zone.now
    signature =
      Stripe::Webhook::Signature.compute_signature(timestamp, event_json, secret)

    "t=#{timestamp.to_i},"\
      "#{Stripe::Webhook::Signature::EXPECTED_SCHEME}"\
      "=#{signature}"
  end
end

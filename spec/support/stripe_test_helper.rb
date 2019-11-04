module StripeTestHelper
  def stripe_event_signature(event_json, secret)
    timestamp = Time.now.to_i
    signing_format = "#{timestamp}.#{event_json}"
    signature = Stripe::Webhook::Signature.send(:compute_signature, signing_format, secret)
    scheme = Stripe::Webhook::Signature::EXPECTED_SCHEME
    "t=#{timestamp},#{scheme}=#{signature}"
  end
end

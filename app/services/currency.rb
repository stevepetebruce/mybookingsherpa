class Currency
  def self.iso_to_symbol(iso)
    { "eur": "€", "gbp": "£", "usd": "$" }.fetch(iso.to_sym)
  end

  def self.human_readable(amount_in_cents)
    format("%.2f", (amount_in_cents / 100.0)) if amount_in_cents
  end
end

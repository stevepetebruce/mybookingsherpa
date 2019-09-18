class Currency
  def self.country_code_to_iso(country_code)
    return "gbp" if country_code == "gb"
    return "usd" if country_code == "us"

    "eur"
  end

  def self.iso_to_symbol(iso)
    { "eur": "€", "gbp": "£", "usd": "$" }.fetch(iso.to_sym)
  end

  def self.human_readable(amount_in_cents)
    format("%.2f", (amount_in_cents / 100.0)) if amount_in_cents
  end
end

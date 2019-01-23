class Currency
  def self.iso_to_symbol(iso)
    { "eur": "€", "gbp": "£", "usd": "$" }.fetch(iso.to_sym)
  end
end

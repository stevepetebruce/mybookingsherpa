unless Rails.env.test?
  # - - - - - -
  # Throttlers:

  # Throttle sign up attempts every 24 hours
  Rack::Attack.throttle("limit sign ups per day", limit: 2, period: 24.hours) do |request|
    request.ip if request.path == "/guides" && request.post?
  end

  # Throttle login attempts for a given email parameter per minute
  # Return the email as a discriminator on POST /login requests
  Rack::Attack.throttle("limit logins per email", limit: 5, period: 60.seconds) do |request|
    request.params["email"] if request.path == "/guides/sign_in" && request.post?
  end

  # Throttle login attempts for a given ip address per minute
  # Return the email as a discriminator on POST /login requests
  Rack::Attack.throttle("limit logins per email", limit: 5, period: 60.seconds) do |request|
    request.ip if request.path == "/guides/sign_in" && request.post?
  end

  # - - - - - -
  # Blockers:

  # NB: Requests are blocked if the return value is truthy
  Rack::Attack.blocklist("block all access to scrapers hitting get /1, etc") do |request|
    request.path.end_with?("/1", "/.env") && request.get?
  end

  # By IP adress:
  def self.blocked_ip_addresses_403
    ["13.237.199.116", "185.234.216.58", "194.53.148.71", "51.77.249.198", "80.82.70.206"] +
      ["199.229.249.162", "91.132.136.50", "37.235.66.207", "62.177.43.154", "178.95.240.188"] +
      ["178.176.112.213", "77.109.55.209", "185.46.8.135", "123.138.79.105", "132.145.34.57"] +
      ["188.40.33.78", "192.99.36.177", "51.158.191.84", "106.59.245.48", "66.249.79.90"]
  end

  def self.blocked_ip_addresses_404
    []
  end

  def self.blocked_ip_addresses_503
    []
  end

  Rack::Attack.blocklist("block with 403") do |req|
    blocked_ip_addresses_403.include?(req.ip)
  end

  Rack::Attack.blocklist("block with 404") do |req|
    blocked_ip_addresses_404.include?(req.ip)
  end

  Rack::Attack.blocklist("block with 404 all access to php, etc scrapers") do |req|
    req.path =~ /.(php|asd|ashx|asp)/
  end

  Rack::Attack.blocklist("block with 503") do |req|
    blocked_ip_addresses_503.include?(req.ip)
  end
end

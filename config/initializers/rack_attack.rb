# - - - - - -
# Throttlers:

unless Rails.env.test?
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
  Rack::Attack.blocklist("block all access to php scrapers") do |request|
    request.path.end_with?(".php")
  end

  Rack::Attack.blocklist("block all access to scrapers hitting get /1") do |request|
    request.path.end_with?("/1") && request.get?
  end
end
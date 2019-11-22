# A wrapper around env vars, etc.
class Settings
  class << self
    def env_staging?
      ENV.fetch("BASE_DOMAIN") == "https://mybookingsherpa-staging.herokuapp.com"
    end
  end
end

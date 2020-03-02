class Regex
  # Used in either form or app versions below. For consistency, only change these.
  RAW_EMAIL = %r{[\w.+]+@[\w.]+}.freeze
  RAW_NAME = %r{[\sa-zA-Z0-9_.'\-]+}.freeze

  COUNTRY = %r{\A[A-Z]{2,3}\z}.freeze
  EMAIL = %r{\A#{Regex::RAW_EMAIL.source}\z}.freeze
  EMAIL_FORM = %r{^#{Regex::RAW_EMAIL.source}$}.freeze
  NAME = %r{\A#{Regex::RAW_NAME.source}\z}
  NAME_FORM = %r{^#{Regex::RAW_NAME.source}$}.freeze
  PHONE_NUMBER = %r{\A[0-9+.x()\-\s]{7,}\z}.freeze
end

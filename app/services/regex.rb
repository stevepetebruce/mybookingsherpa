class Regex
  COUNTRY = %r{\A[A-Z]{2,3}\z}.freeze
  EMAIL = %r{\A[\w.]+@\w+\.{1}[a-zA-Z]{2,}\z}.freeze
  NAME = %r{\A[\sa-zA-Z0-9_.'\-]+\z}.freeze
  PHONE_NUMBER = %r{\A[0-9+.x()\-\s]{7,}\z}.freeze
end

# Represents users who go on trips
class Guest < User
  has_and_belongs_to_many :trips, foreign_key: 'user_id'
end

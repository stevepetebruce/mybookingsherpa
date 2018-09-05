# Represents users who host trips
class Guide < User
  has_and_belongs_to_many :trips, foreign_key: 'user_id'
end

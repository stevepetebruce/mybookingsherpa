class Guest < ApplicationRecord
  UPDATABLE_FIELDS = %i[address allergies city country county
                        date_of_birth dietary_requirements
                        medical_conditions name
                        next_of_kin_name next_of_kin_phone_number
                        phone_number post_code].freeze
  UPDATABLE_SOURCE_FIELD_POSTFIX = "_booking".freeze

  after_update :set_updatable_fields

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum allergies: %i[dairy eggs nuts penicillin soya]
  enum dietary_requirements: %i[other vegan vegetarian]

  has_many :bookings
  has_many :trips, through: :bookings

  validates :email, format: /\A\w+@\w+\.{1}[a-zA-Z]{2,}\z/, presence: true, uniqueness: true
  validates :name, format: /\A[\sa-zA-Z0-9_.'\-]+\z/, allow_blank: true
  validates :phone_number, format: /\A[0-9+.x()\-\s]{7,}\z/, allow_blank: true

  def password_required?
    false
  end

  private

  def blank_updatable_attributes
    updatable_attributes.reject { |k, _v| read_attribute(k).present? }
  end

  def set_updatable_fields
    return if blank_updatable_attributes.empty?

    update_columns(blank_updatable_attributes)
  end

  def source_attributes
    attributes.slice(*UPDATABLE_FIELDS.map { |field| "#{field}#{UPDATABLE_SOURCE_FIELD_POSTFIX}" })
  end

  def updatable_attributes
    source_attributes.map { |k, v| [k.gsub(UPDATABLE_SOURCE_FIELD_POSTFIX, ""), v] }.to_h
  end
end

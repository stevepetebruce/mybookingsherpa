module CompanyPeople
  # Creates CompanyPeople
  class Factory
    def initialize(email, first_name, last_name, organisation, relationship, stripe_person_id)
      @email = email
      @first_name = first_name
      @last_name = last_name
      @organisation = organisation
      @relationship = relationship
      @stripe_person_id = stripe_person_id
    end

    def create
      @organisation.company_people.create(attributes)
    end

    def self.create(email, first_name, last_name, organisation, relationship, stripe_person_id)
      new(email, first_name, last_name, organisation, relationship, stripe_person_id).create
    end

    private

    def attributes
      {
        email: @email,
        first_name: @first_name,
        last_name: @last_name,
        relationship: @relationship,
        stripe_person_id: @stripe_person_id
      }
    end
  end
end

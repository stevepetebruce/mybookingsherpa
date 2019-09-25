module CompanyPeople
  # Creates CompanyPeople
  class Factory
    def initialize(first_name, last_name, organisation, stripe_person_id)
      @first_name = first_name
      @last_name = last_name
      @organisation = organisation
      @stripe_person_id = stripe_person_id
    end

    def create
      @organisation.company_people.create(attributes)
    end

    def self.create(first_name, last_name, organisation, stripe_person_id)
      new(first_name, last_name, organisation, stripe_person_id).create
    end

    private

    def attributes
      {
        first_name: @first_name,
        last_name: @last_name,
        stripe_person_id: @stripe_person_id
      }
    end
  end
end

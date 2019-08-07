module StripeAccounts
  class StripeApiPerson
    def initialize(stripe_account)
      @stripe_account = stripe_account
    end

    def create
      External::StripeApi::Person.create(account_id: @stripe_account.stripe_account_id,
                                         person_token: @stripe_account.token_person)
    end
  end
end

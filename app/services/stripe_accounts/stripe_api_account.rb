module StripeAccounts
  class StripeApiAccount
    def initialize(token_account, country_code)
      @country_code = country_code
      @token_account = token_account
    end

    def create
      External::StripeApi::Account.create(account_token: @token_account,
                                          country_code: @country_code)
    end
  end
end

module Onboardings
  class AssignCountrySpecificDataJob < ApplicationJob
    queue_as :default

    def perform(organisation, ip_address)
      organisation.update_columns(country_code: country_code(ip_address),
                                  currency: currency(ip_address))
    end

    private

    def country_code(ip_address)
     @country_code ||= External::IpStackApi.country_code(ip_address)
    end

    def currency(ip_address)
      Currency.country_code_to_iso(country_code(ip_address))
    end
  end
end

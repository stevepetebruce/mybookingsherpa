module Onboardings
  class ExampleDataSelector
    def initialize(country_code = "fr")
      @country_code = country_code
    end

    def example_country_data(data_field)
      country_specific_data&.dig(:data, data_field.to_sym)
    end

    private

    def all_example_data
      [
        {
          country_code: "fr",
          data: {
            country_select: ["France", "FR"],
            dob: "1977-12-21",
            email: "e.macron@gmail.com",
            full_name: "Emmanuel Macron",
            ice_name: "Brigitte Macron",
            ice_phone: "+330123456789",
            phone: "+330123456789"
          },
        },
        {
          country_code: "gb",
          data: {
            country_select: ["United Kingdom", "GB"],
            dob: "1964-06-19",
            email: "b.johnson@gmail.com",
            full_name: "Boris Johnson",
            ice_name: "Nigel Farage",
            ice_phone: "+440123456789",
            phone: "+440123456789"
          }
        },
        {
          country_code: "us",
          data: {
            country_select: ["USA", "US"],
            dob: "1946-06-14",
            email: "d.trump@gmail.com",
            full_name: "Donald Trump",
            ice_name: "Melania Trump",
            ice_phone: "+10123456789",
            phone: "+10123456789"
          }
        }
      ]
    end

    def country_specific_data
      @country_specific_data ||= 
        all_example_data.detect { |example_datum| example_datum[:country_code] == @country_code }
    end
  end
end

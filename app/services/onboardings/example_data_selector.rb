module Onboardings
  class ExampleDataSelector
    def initialize(index)
      @chosen_example = all_example_data[index].presence || all_example_data[1]
    end

    def value(data_field)
      @chosen_example&.dig(:data, data_field.to_sym)
    end

    private

    def all_example_data
      [
        {
          country_code: "us",
          data: {
            country_select: ["USA", "US"],
            dob: "1963-12-18",
            email: "b.pitt_1992@gmail.com",
            full_name: "Brad Pitt",
            ice_name: "Angelina Jolie",
            ice_phone: "+330123456789",
            phone: "+330123456789"
          },
        },
        {
          country_code: "us",
          data: {
            country_select: ["USA", "US"],
            dob: "1962-07-03",
            email: "t.cruise_1995@hotmail.com",
            full_name: "Tom Cruise",
            ice_name: "Nicole Kidman",
            ice_phone: "+440123456789",
            phone: "+440123456789"
          }
        },
        {
          country_code: "us",
          data: {
            country_select: ["USA", "US"],
            dob: "1974-11-11",
            email: "leonardo.dicaprio_2000@yahoo.com",
            full_name: "Leonardo DiCaprio",
            ice_name: "Brad Pitt",
            ice_phone: "+10123456789",
            phone: "+10123456789"
          }
        }
      ]
    end
  end
end

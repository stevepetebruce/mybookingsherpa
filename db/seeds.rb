organisation = Organisation.create(currency: "eur", name: "Alp Adventures")

Trip.create(name: "Mountain Bike Trip",
            start_date: Date.today + 1.weeks,
            end_date: Date.today + 2.weeks,
            maximum_number_of_guests: 12,
            description: "A week long amazing trip on through the mountains",
            full_cost: 500,
            organisation: organisation)

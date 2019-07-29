guide = Guide.create(email: "test_alpadventureguide@hotmail.com", name: "A Guide", password: ENV.fetch("SEED_GUIDE_PASSWORD"))
organisation = Organisation.create(currency: "eur", deposit_percentage: 10, full_payment_window_weeks: 6, name: "Alp Adventures Test", stripe_account_id: ENV.fetch("STRIPE_TEST_ACCOUNT_NUMBER"), subdomain: "alpadventurestest")
OrganisationMembership.create(organisation: organisation, guide: guide, owner: true)

puts 'guide ' + guide.inspect
puts 'organisation ' + organisation.inspect

puts 'guide ' + guide.errors.inspect
puts 'organisation ' + organisation.errors.inspect

# Organisation logo image
organisation.logo_image.attach(io: File.open("app/javascript/images/logos/alp-adventures-logo.png"), filename: "alp-adventures-logo.png")

# Trips
guide.trips.create(name: "Rewild",
                   start_date: Time.new(2019, 2, 22),
                   end_date: Time.new(2019, 2, 27),
                   maximum_number_of_guests: 8,
                   description: "Get away from your busy life for 6 days to rewild in the overwhelming beauty of the backcountry. Escape the hustle and bustle of the ski area and discover the peace of the snowy mountains. Climb over cols, walk through woodland trails, build an igloo and enjoy incredible sunsets. At the campfire, tuck into a home-made meal and enjoy the magical experience of a night in an authentic mountain hut.",
                   full_cost: 850,
                   organisation: organisation,
                   slug: "Rewild".parameterize(separator: "_").truncate(80, omission: ""))
guide.trips.create(name: "Ski Safari",
                   start_date: Time.new(2019, 3, 10),
                   end_date: Time.new(2019, 3, 13),
                   maximum_number_of_guests: 15,
                   description: "Explore the Grand Massif from three different angles. Every morning you'll step into your bindings from a different part of this amazing ski area. Your private guide will show you the best slopes, the deepest powder and the best lunches in the Grand Massif.",
                   full_cost: 499,
                   organisation: organisation,
                   slug: "Ski Safari".parameterize(separator: "_").truncate(80, omission: ""))
guide.trips.create(name: "Backcountry Basecamp",
                   start_date: Time.new(2019, 3, 22),
                   end_date: Time.new(2019, 3, 24),
                   maximum_number_of_guests: 8,
                   description: "A 3 days touring adventure into the wild. A group of like-minded freeriders, tucked away in the background. A tent, an igloo, food and some drinks, ski's or boards and above all; a pair of skins to hike up the mountain and shred back down to basecamp!",
                   full_cost: 595,
                   organisation: organisation,
                   slug: "Backcountry Basecamp".parameterize(separator: "_").truncate(80, omission: ""))
guide.trips.create(name: "Wintergration Station",
                   start_date: Time.new(2019, 4, 22),
                   end_date: Time.new(2019, 4, 25),
                   maximum_number_of_guests: 15,
                   description: "A three days snow adventure; as soon on TV. Come over for a mountain adventure away from the crowded ski slopes. Enjoy the peace and beauty of the back country in the snowy mountains around Samoëns.",
                   full_cost: 499,
                   organisation: organisation,
                   slug: "Wintergration Station".parameterize(separator: "_").truncate(80, omission: ""))
guide.trips.create(name: "A mindful snowshoe retreat",
                   start_date: Time.new(2019, 3, 9),
                   end_date: Time.new(2019, 3, 16),
                   maximum_number_of_guests: 8,
                   description: "6 days introduction into mindful snowshoeing. Join us on this trip for a daily snowshoe hike in a winter wonderland to introduce you to mindful snowshoeing. You will learn how to leave interfering thoughts behind, to enable your mind and body to feel energised, relaxed and fully present. And how about a 2 days snowshoe journey with a night in a hut, tucked away in the snowy mountains?!",
                   full_cost: 1250,
                   organisation: organisation,
                   slug: "A mindful snowshoe retreat".parameterize(separator: "_").truncate(80, omission: ""))
guide.trips.create(name: "24h in the mountains",
                   start_date: Time.new(2019, 6, 9),
                   end_date: Time.new(2019, 6, 10),
                   maximum_number_of_guests: 15,
                   description: "A quick escape from the ratrace. Getting away from your daily routine into the inknown of the mountains for just 24 hours can have a huge impact. Grab a flight to Geneva, jump in the van and join us for an awesome memorable mountain adventure.",
                   full_cost: 150,
                   organisation: organisation,
                   slug: "24h in the mountains".parameterize(separator: "_").truncate(80, omission: ""))
guide.trips.create(name: "Best of the Haute Savoie",
                   start_date: Time.new(2019, 7, 10),
                   end_date: Time.new(2019, 7, 16),
                   maximum_number_of_guests: 8,
                   description: "Six days of singletrack shredding in six different bike spots. Over 6 days you'll shred the best single tracks in Samoens, Les Portes du Soleil, la Clusaz, Salève, Chamonix or the hidden trails of la Vallée Verte. A combination of ski lifts and pedalling will get you to the best spots. You'll enjoy the view, open the suspension and drop the seats for another 1000 metre descent.",
                   full_cost: 895,
                   organisation: organisation,
                   slug: "Best of the Haute Savoie".parameterize(separator: "_").truncate(80, omission: ""))
guide.trips.create(name: "Bucket Project",
                   start_date: Time.new(2019, 8, 1),
                   end_date: Time.new(2019, 8, 4),
                   maximum_number_of_guests: 8,
                   description: "A 4 days journey into the unknown. Four days of adventure: a journey off the beaten track, into the still. Things none of us have ever done before...",
                   full_cost: 1950,
                   organisation: organisation,
                   slug: "Bucket Project".parameterize(separator: "_").truncate(80, omission: ""))
guide.trips.create(name: "Family adventures",
                   start_date: Time.new(2019, 8, 10),
                   end_date: Time.new(2019, 8, 17),
                   maximum_number_of_guests: 16,
                   description: "A week full of outdoor action. Together with other parent(s) and their children, you will spend a full week in outdoor paradise \"la Vallée du Giffre. You will stay in a big and comfortable chalet with several double- and familyrooms, on a halfboard base. During 5 days we will organise you some awesome outdoor activities, like: mountainbiking, whitewater-rafting and rockclimbing. And what do you think about a two-days mountain adventure with a night in a remote mountainhut....?!",
                   full_cost: 799,
                   organisation: organisation,
                   slug: "Family adventures".parameterize(separator: "_").truncate(80, omission: ""))
guide.trips.create(name: "Tour du Mont Blanc",
                   start_date: Time.new(2019, 9, 10),
                   end_date: Time.new(2019, 9, 17),
                   maximum_number_of_guests: 7,
                   description: "6 days enduro bike trip around the highest mountain of western Europe. An awesome enduro bike trip around the highest mountain of western Europe, that is the famous Tour du Mont Blanc. From Chamonix we ride clockwise through Martigny, to Italy and back into France. We ride through authentic villages, across rustic alpine meadows, surrounded by impressive glaciers and the highest peaks of the Alps. We spend the nights in basic but cosy 2star mountain hotels on a halfboard base. This is an unforgettable bike experience with trails and views you will never forget!",
                   full_cost: 1495,
                   organisation: organisation,
                   slug: "Tour du Mont Blanc".parameterize(separator: "_").truncate(80, omission: ""))
guide.trips.create(name: "Trans74",
                   start_date: Time.new(2019, 7, 1),
                   end_date: Time.new(2019, 7, 7),
                   maximum_number_of_guests: 8,
                   description: "a 6 days bike adventures through the Haute Savoie. Starting from Samoëns we link up the best bike spots of the Haute Savoie. We use a skilift to climb the first hundreds of meters, followed by a climb to arrive at a remote mountainhut where we'll spend the night. An early sunset wakes you up, while you get ready for another awesome day of singletrack shredding.",
                   full_cost: 895,
                   organisation: organisation,
                   slug: "Trans74".parameterize(separator: "_").truncate(80, omission: ""))

# Guests:
# Basic details:
15.times.each do
  guest = Guest.create(email: Faker::Internet.email,
                       name: Faker::Name.name,
                       name_booking: Faker::Name.name)

  puts "Guest errors: #{guest.errors.full_messages}" if guest.errors.full_messages.present?
end

# Full details:
15.times.each do
  create_allergies = [true, false].sample
  create_dietary_requirements = [true, false].sample
  create_other_information = [true, false].sample

  allergy_name = %i[dairy eggs nuts soya].sample
  dietary_requirement_name = %i[other vegan vegetarian].sample
  other_information = create_other_information ? Faker::Lorem.sentence : nil

  email = Faker::Internet.email
  name = Faker::Name.name

  guest = Guest.create(country_booking: Faker::Address.country_code,
                       date_of_birth_booking: Faker::Date.birthday(18, 65),
                       email: email,
                       email_booking: email,
                       other_information_booking: other_information,
                       name: name,
                       name_booking: name,
                       next_of_kin_name_booking: Faker::Name.name,
                       next_of_kin_phone_number_booking: Faker::PhoneNumber.cell_phone,
                       phone_number_booking: Faker::PhoneNumber.cell_phone)

  puts "Guest errors: #{guest.errors.full_messages}" if guest.errors.full_messages.present?

  guest.allergies.create(name: allergy_name) if create_allergies
  guest.dietary_requirements.create(name: dietary_requirement_name) if create_dietary_requirements
end

# Bookings
3.times.each do
  Guest.all.each do |guest|
    trip = Trip.all.sample

    next if [true, false].sample # randomise the creation a little bit
    next if trip.bookings.count >= trip.maximum_number_of_guests

    booking = Booking.create(email: guest.email, name: guest.name, guest: guest, trip: trip)
    Payment.create(amount: booking.full_cost, booking: booking) if [true, false].sample

    puts "Booking errors: #{booking.errors.full_messages}" if booking.errors.full_messages.present?
  end
end

# Developer friendly logging
Trip.all.each { |trip| puts "Trip id: #{trip.id}" }
puts "Guide details: email: test_alpadventureguide@hotmail.com. Password: see SEED_GUIDE_PASSWORD env var"

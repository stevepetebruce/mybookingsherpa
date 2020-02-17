FactoryBot.define do
  factory :stripe_event, class: Hash do
    transient do
      meant_for_this_environment { true }
      json { {} }
    end

    skip_create

    initialize_with do
      if meant_for_this_environment
        json["data"]["object"]["charges"]["data"]&.first["metadata"].merge!({ base_domain: ENV.fetch("BASE_DOMAIN") })
        json["data"]["object"]["metadata"].merge!({ base_domain: ENV.fetch("BASE_DOMAIN") })
        json
      else
        json["data"]["object"]["charges"]["data"]&.first["metadata"].merge!({ base_domain: Faker::Lorem.word })
        json["data"]["object"]["metadata"].merge!({ base_domain: Faker::Lorem.word })
        json
      end

    rescue NoMethodError => e
      json
    end
  end
end

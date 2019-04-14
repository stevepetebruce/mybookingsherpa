desc "This task adds slugs to older trips that do not already have a slug"
task :add_slugs_to_older_trips => :environment do
  puts "Runnning task"

  Trip.all { |trip| trip.send(:set_slug) }

  puts "Finished runnning task"
end

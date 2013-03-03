task :nightly => :environment do
  desc "nightly housekeeping for Blue Dot Analytical Engine"

  ServiceAccount.nightly_task
end

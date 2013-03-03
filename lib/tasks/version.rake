# lib/tasks/version.rake
task :version => :environment do
  puts Padrino.version
end

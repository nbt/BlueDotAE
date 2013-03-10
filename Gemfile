# -*- Mode: Ruby; -*-
source :rubygems

# Server requirements
gem "thin"

# Project requirements
gem "rake"
gem "sinatra-flash", :require => "sinatra/flash"
gem "mechanize"
gem "zipruby"
gem "attr_encryptor"

# Component requirements
gem "bcrypt-ruby", :require => "bcrypt"
gem "sass"
gem "haml"
gem "dm-postgres-adapter"
gem "dm-validations"
gem "dm-timestamps"
gem "dm-migrations"
gem "dm-constraints"
gem "dm-aggregates"
gem "dm-core"
gem "dm-types"
gem "dm-transactions"

group :development do
  gem "debugger"
  gem "ruby-prof"
end

group :test do
  gem "autotest-standalone"
  gem "autotest-growl"
  gem "autotest-fsevent"
  gem "factory_girl"
  gem "rack-test", :require => "rack/test"
  gem "rspec"
  gem "simplecov"
  gem "timecop"
  gem "vcr"
  gem "webmock"
end

# Padrino Stable Gem
gem "padrino", "0.10.7"


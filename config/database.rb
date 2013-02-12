##
# A MySQL connection:
# DataMapper.setup(:default, 'mysql://user:password@localhost/the_database_name')
#
# # A Postgres connection:
# DataMapper.setup(:default, 'postgres://user:password@localhost/the_database_name')
#
# # A Sqlite3 connection
# DataMapper.setup(:default, "sqlite3://" + Padrino.root('db', "development.db"))
#

DataMapper.logger = logger
DataMapper::Property::String.length(255)

user = ENV['POSTGRESQL_USERNAME'] || 'root'
pass = ENV['POSTGRESQL_PASSWORD'] || ''
case Padrino.env
when :development then DataMapper.setup(:default, "postgres://#{user}:#{pass}@localhost/blue_dot_ae_development")
when :production  then DataMapper.setup(:default, "postgres://#{user}:#{pass}@localhost/blue_dot_ae_production")
when :test        then DataMapper.setup(:default, "postgres://#{user}:#{pass}@localhost/blue_dot_ae_test")
end

PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")

require 'factories'
require 'factories/sequences'
require 'stringio'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
  DataMapper.auto_migrate!
end

def app
  ##
  # You can handle all padrino applications using instead:
  #   Padrino.application
  BlueDotAe.tap { |app|  }
end

def reset_db
  DataMapper::Model.descendants.each {|d| d.destroy!}
end

# Returns a hash of :stdout and :stderr captured, e.g.
# s = with_output_captured { do_some_test }
# s[:stderr].should =~ /^error/
def with_output_captured
  begin
    o_stdout, o_stderr = $stdout, $stderr
    $stdout, $stderr = StringIO.new, StringIO.new
    yield
    {:stdout => $stdout.string, :stderr => $stderr.string}
  ensure
    $stdout, $stderr = o_stdout, o_stderr
  end
end

# Workaround for https://github.com/travisjeffery/timecop/issues/72
def truncate_to_seconds(datetime)
  DateTime.new(datetime.year, datetime.month, datetime.day, datetime.hour, datetime.minute, datetime.second)
end

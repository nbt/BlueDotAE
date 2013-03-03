# Run 'rake create_version' AFTER 'git commit' but BEFORE 'git push'.
task :create_version => :environment do
  desc "create VERSION.  Use MAJOR_VERSION, MINOR_VERSION, BUILD_VERSION to override defaults"

  root_dir = File.dirname(ENV["BUNDLE_GEMFILE"])
  puts("root_dir = #{root_dir}")
  version_file = "#{root_dir}/config/version.rb"
  major = ENV["MAJOR_VERSION"] || 0
  minor = ENV["MINOR_VERSION"] || 0
  build = ENV["BUILD_VERSION"] || `git describe --always --tags`
  version_string = "VERSION = #{[major.to_s, minor.to_s, build.strip]}\n"
  File.open(version_file, "w") {|f| f.print(version_string)}
  $stderr.print(version_string)
end

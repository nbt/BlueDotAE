module ServiceProvider

  # If this file is named "apps/models/foo.xyz", require each file
  # with a ".xyz" extension found under "apps/models/foo/" and
  # (recursively) under its subdirectories

  module_dir = File.join(File.dirname(__FILE__), 
                         File.basename(__FILE__, File.extname(__FILE__)))
  pattern = File.join(module_dir, "**", "*" + File.extname(__FILE__))
  Dir[pattern].each {|f| require f }

end

module BDUtilities
  extend self

  def string_to_class(string)
    string.split('::').inject(Object) { |cls, class_name|  cls.const_get(class_name) }
  end

  # If file is "apps/models/foo.xyz", require each file with a ".xyz"
  # extension found under "apps/models/foo/" and (recursively) under
  # its subdirectories
  def require_submodules(file)
    ext = File.extname(file)
    module_dir = File.join(File.dirname(file), File.basename(file, ext))
    pattern = File.join(module_dir, "**", "*" + ext)
    Dir[pattern].each {|f| require f }
  end

end

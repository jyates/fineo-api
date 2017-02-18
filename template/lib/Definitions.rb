

module Definitions

  # Load all the definitions in a directory. Any sub-directories are also visited, but added to
  # the top-level of the definition hierarchy
  def load_definitions(dir)
    definitions = {}
    Dir.foreach(dir) do |item|
      dirpath = dir + '/' + item
      next if item == '.' or item == '..'
      # its a directory, so load all the definitions from that directory
      if File.directory?(dirpath)
        defs = load_definitions(dirpath)
        definitions.merge!(defs)
      else
        # its just a simple file, so load it normally.
        definitions[item.sub(".json", "")] = File.read(File.join(dir,item))
      end
    end
    definitions
  end

end

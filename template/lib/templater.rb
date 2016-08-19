
require 'templates'
require 'dir_builder'

class Templater
  include Templates

  def initialize(outputName, suffix, source, parents)
    @output = "#{outputName}-#{suffix}"
    @source = source
    @parents = parents
  end

  def template(root, assigned)
    includes = load_definitions(File.join(@source, Templates::INCLUDES)).merge(assigned)
    definitions = load_definitions(File.join(@source, Templates::DEFINITIONS))

    # Build the paths from the root
    raw_paths = {}
    @parents.each{|name|
      dir = File.join(@source, name)
      builder = DirBuilder.new(dir)
      raw_paths.merge! builder.build(includes, definitions)
    }

    paths = {}
    raw_paths.each{|k,v|
      k = k.gsub("./input", "")
      k = k.gsub(".json", "")
      paths[k] = v
    }

    assigned["paths"] = map_names_to_array(paths)
    assigned["includes"] = includes
    assigned["definitions"] = map_names_to_array(definitions)
    file = template_file(root, assigned)
    IO.write(@output, file)
  end

private

  def map_names_to_array(map)
    map.flat_map{|path, content|
      "\"#{path}\" : #{content}"
    }
  end
end

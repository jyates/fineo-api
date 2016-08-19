
require 'templates'
require 'dir_builder'
require 'json'

class Templater
  include Templates

  def initialize(info, parents)
    @info = info
    @parents = parents
  end

  def template(name, outputName, suffix)
    output = "#{outputName}-#{suffix}"
    root = @info.root
    assigned = @info.assigned.dup
    assigned["api"]["title"] = "fineo-#{name}"
    includes = @info.includes
    definitions = @info.definitions

    # Build the paths from the root
    raw_paths = {}
    @parents.each{|name|
      builder = DirBuilder.new(name)
      raw_paths.merge! builder.build(includes, definitions)
    }

    paths = {}
    raw_paths.each{|k,v|
      k = k.gsub("./input", "")
      k = k.gsub(".json", "")
      k = k.sub(@info.input, "")
      paths[k] = v
    }

    assigned["paths"] = map_names_to_array(paths)
    assigned["includes"] = includes
    assigned["definitions"] = map_names_to_array(definitions)
    file = template_file(root, assigned)

    # pretty print the json - helps with visual validation
    json = JSON.parse(file)
    File.open(output,"w") do |f|
      f.write(JSON.pretty_generate(json))
    end
  end

private

  def map_names_to_array(map)
    map.flat_map{|path, content|
      "\"#{path}\" : #{content}"
    }
  end
end

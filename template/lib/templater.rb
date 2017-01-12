
require 'templates'
require 'deep_merge'
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

    # need to update the includes values for the templated files
    # Build the paths from the root
    raw_paths = {}
    @parents.each{|name|
      builder = DirBuilder.new(name)
      raw_paths.merge! builder.build(includes, definitions)
    }

    paths = {}
    raw_paths.each{|k,v|
      k = k.gsub(".json", "")
      k = k.sub(@info.input, "")
      paths[k] = v
    }

    assigned["definitions"] = map_names_to_array(definitions)
    includes = template_map_content(includes, includes.deep_merge(assigned))
    assigned["paths"] = map_names_to_array(template_map_content(paths, includes.deep_merge(assigned)))
    # Set this after to avoid cyclic references
    assigned["includes"] = includes

    file = template_file(root, assigned)
    begin
      # pretty print the json - helps with visual validation
      json = JSON.parse(file)
    rescue JSON::ParserError => e
      output = "#{output}_failed.json"
      puts "Failed to generate correct json! Writing current state to: #{output}"
      File.open(output,"w") do |f|
        f.write(file)
      end
      raise e.message.split("\n").first
    end
    File.open(output,"w") do |f|
      f.write(JSON.pretty_generate(json))
    end
  end

private

  def template_map_content(map, assigned)
    out = {}
    map.each{|file, content|
      out[file] = template_content(content, assigned)
    }
    return out
  end

  def map_names_to_array(map)
    map.flat_map{|path, content|
      "\"#{path}\" : #{content}"
    }
  end
end

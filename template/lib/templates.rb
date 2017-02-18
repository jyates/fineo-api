
require 'liquid'
require 'templates'
require 'deep_merge'
require 'dir_builder'
require 'json'

module Templates
  DEFINITIONS = "definitions"
  INCLUDES = "includes"

  def self.template_file(file, assigned)
    Templates.template_raw_content(File.read(file), assigned)
  end

  def self.template_raw_content(content, assigned)
    template = Liquid::Template.parse(content, :error_mode => :strict)
    output = template.render!(assigned, { strict_variables: true})
    puts template.errors
    return output
  end

  def self.write(content, name)
    begin
      # pretty print the json - helps with visual validation
      json = JSON.parse(content)
    rescue JSON::ParserError => e
      output = "#{name}_failed.json"
      puts "Failed to generate correct json! Writing current state to: #{output}"
      begin
        File.write(output, content)
      rescue RuntimeError => e1
        puts "Failed writing content: #{e1}"
      end
      puts "JSON fail: #{e}"
      raise e.message.split("\n").first
    end
    File.write(name, JSON.pretty_generate(json))
  end

  class Templater
    def initialize(info, parents)
      @info = info
      @parents = parents
    end

    def template_content(name)
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
        #require 'pp'
        #puts "------------ #{k} ------------"
        #pp v
      }

      assigned["definitions"] = map_names_to_array(definitions)
      includes = template_map_content(includes, includes.deep_merge(assigned))
      assigned["paths"] = map_names_to_array(template_map_content(paths, includes.deep_merge(assigned)))
      # Set this after to avoid cyclic references
      assigned["includes"] = includes

      # templates the contents of the file with the assigned properties
      return Templates.template_file(root, assigned)
    end

    def template(name, outputName, suffix)
      output = "#{outputName}-#{suffix}"
      file = template_content(name)
      Templates.write(file, output)
    end

  private

    def template_map_content(map, assigned)
      out = {}
      map.each{|file, content|
        out[file] = Templates.template_raw_content(content, assigned)
      }
      return out
    end

    def map_names_to_array(map)
      map.flat_map{|path, content|
        "\"#{path}\" : #{content}"
      }
    end
  end
end


require 'liquid'

module Templates
  DEFINITIONS = "definitions"
  INCLUDES = "includes"

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

  def template_file(file, assigned)
    template_content(File.read(file), assigned)
  end

  def template_content(content, assigned)
    template = Liquid::Template.parse(content, :error_mode => :strict)
    output = template.render!(assigned, { strict_variables: true})
    puts template.errors
    return output
  end
end

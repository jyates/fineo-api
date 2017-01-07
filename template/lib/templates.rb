
require 'liquid'

module Templates
  DEFINITIONS = "definitions"
  INCLUDES = "includes"

  def load_definitions(dir)
    definitions = {}
    Dir.foreach(dir) do |item|
      next if item == '.' or item == '..'
      definitions[item.sub(".json", "")] = File.read(File.join(dir,item))
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

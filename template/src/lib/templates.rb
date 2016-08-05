
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
    Liquid::Template.parse(File.read(file)).render(assigned)
  end
end

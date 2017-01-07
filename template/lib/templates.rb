
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
    includes = assigned["includes"]
    unless includes.nil?
      out = includes["single_event_mapping"]
      puts "(templater) Single event mapping: #{out}" unless out.nil?
    end

    puts "Templating content: \n#{content}"
    Liquid::Template.error_mode = :strict
    template = Liquid::Template.parse(content)
    # puts "assigned: \n #{assigned}"
    output = template.render(assigned)
    puts template.errors
    return output
  end
end

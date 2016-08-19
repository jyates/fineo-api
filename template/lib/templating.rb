
require 'liquid'
require 'templater'
require 'template_info'
require 'templates'

module Templating

  def template(info, output)
    external = []
    Dir.glob(File.join(info.input, "/*")).each{|dir|
      next unless File.directory?(dir)

      name = File.basename(dir)
      next if name == Templates::INCLUDES || name == Templates::DEFINITIONS
      external << dir unless EXTERNAL_EXCLUDES.include? name

      template_sources(info, name, output, [dir])
    }
    external
  end

  def template_sources(info, name, output, dirs, suffix="swagger-integrations,authorizers.json")
    output = File.join(output, name)
    Templater.new(info, dirs).template(output, suffix)
  end
end

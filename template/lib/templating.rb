
require 'liquid'
require 'templater'
require 'template_info'
require 'templates'
require 'deep_merge'

module Templating

  def get_assigns(props)
    case props
      when String
        assigns = JSON.parse(File.read(props)
      when Array
        assigns = {}
        props.each{|file|
          assigns = assigns.deep_merge JSON.parse(File.read(file)) if File.exists? file
        }
      when nil
        raise "Must provide a properties file!"
    end
    assigns
  end

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
    Templater.new(info, dirs).template(name, output, suffix)
  end
end


require 'ostruct'
require 'json'
require 'optparse'
require 'liquid'
require 'templater'
require 'template_info'
require 'templates'
require 'deep_merge'

module Templating

  def parse(args, options)
    OptionParser.new do |opts|
      opts.banner = "Usage: template.rb [options]"
      opts.separator "Liquid based templating for the Fineo API"
      opts.separator "  Options:"

      opts.on("-o", "--output DIRECTORY", "Output directory. Default: #{options[:output]}") do |v|
        options[:output] = v
        #ensure the output directory exists
        FileUtils.mkdir_p v
      end

      opts.on("-i", "--input DIRECTORY", "Input directory. Default: #{options[:input]}") do |v|
        options[:input] = v
      end

      opts.on("--stream props,overrides", Array, "Comma separated properties/overrides for the "+
        "stream api") do |stream|
        options[:stream] = stream
      end

      opts.on("--batch props,overrides", Array, "Comma separated properties/overrides for the "+
        "batch api") do |stream|
        options[:batch] = stream
      end

      opts.on("--schema props,overrides", Array, "Comma separated properties/overrides for the "+
        "schema api") do |stream|
        options[:schema] = stream
      end

      opts.on("--schema-internal props,overrides", Array, "Comma separated properties/overrides "+
        "for the schema api") do |stream|
        options[:schema] = stream
      end

      opts.on("--read props,overrides", Array, "Comma separated properties/overrides for the "+
        "read api") do |stream|
        options[:schema] = stream
      end

      opts.on("--external", "Publish the external API. Uses the above provided properties") do |e|
        options[:external] = true
      end

      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        options[:verbose] = v
      end

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
    end.parse!(args)
  end

  def get_assigns(props)
    case props
      when String
        assigns = JSON.parse(File.read(props))
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

  def template_api(name, root, options)
    return {} if options[name].nil?
    assigns = get_assigns(options[name])
    require 'pp'
    info = TemplateInfo.new(root, assigns, options[:input])
    template(info, options[:output], name.to_s)
    assigns
  end

  def template(info, output, api=nil)
    Dir.glob(File.join(info.input, "/*")).each{|dir|
      next unless File.directory?(dir)

      name = File.basename(dir)
      next if name == Templates::INCLUDES || name == Templates::DEFINITIONS
      next if name != api && !api.nil?

      template_sources(info, name, output, [dir])
    }
  end

  def template_sources(info, name, output, dirs, suffix="swagger-integrations,authorizers.json")
    output = File.join(output, name)
    Templater.new(info, dirs).template(name, output, suffix)
  end
end

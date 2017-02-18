
require 'ostruct'
require 'json'
require 'optparse'
require 'liquid'
require 'template_info'
require 'templates'
require 'deep_merge'
require 'fileutils'

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

      opts.on("--conf DIR", "Directory where api configuration is stored. File names will be " +
        "used as API names") do |dir|
        options[:confs] = dir
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
        "for the schema internal api") do |stream|
        options[:schema_internal] = stream
      end

      opts.on("--schema_internal props,overrides", Array, "Alternative name for schema-internal group properties") do |stream|
        options[:schema_internal] = stream
      end

      opts.on("--meta props,overrides", Array, "Comma separated properties/overrides "+
        "for the metadata api") do |stream|
        options[:meta] = stream
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

  # Template a single API
  # * *Returns* :
  #   - assignments generated from loading this api
  def template_api(name, root, options)
    file = check_name(name, options)
    return {} if file.nil?

    puts "Templating internal apis: #{name} from #{file}" if options[:verbose]
    assigns = get_assigns(file)
    info = TemplateInfo.new(root, assigns, options[:input])
    template(info, options[:output], name.to_s)
    assigns
  end

private

  def check_name(name, options)
    if !options[:confs].nil?
      # check to see if that name is present
      file = File.join("#{options[:confs]}","#{name}.json")
      return file if File.exist?(file)
    end
    return options[name]
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
    Templates::Templater.new(info, dirs).template(name, output, suffix)
  end
end

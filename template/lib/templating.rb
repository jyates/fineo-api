
require 'ostruct'
require 'json'
require 'optparse'
require 'liquid'
require 'templater'
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

      opts.on("--user-info props,overrides", Array, "Comma separated properties/overrides "+
        "for the user info api") do |stream|
        options[:user_info] = stream
      end

      opts.on("--user_info props,overrides", Array, "Alternative name for user-info group properties") do |stream|
        options[:user_info] = stream
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

  def template_batch(name, root, assignments, templates, suffix, options)
    input_dir = options[:input]
    output = options[:output]

    # load the assignments for the group
    templates.each{|template|
      assignments = assignments.deep_merge get_assigns(options[template.to_sym])
    }
    info = TemplateInfo.new(root, assignments, input_dir)

    # convert the templates into their actual directories
    dirs = []
    Dir.glob(File.join(input_dir, "/*")).each{|dir|
      next unless File.directory?(dir)

      file_name = File.basename(dir)
      next if file_name == Templates::INCLUDES || file_name == Templates::DEFINITIONS
      next unless templates.include? file_name
      dirs << dir
    }

    template_sources(info, name, output, dirs, suffix)
  end

  # Template a single API
  # * *Returns* :
  #   - assignments generated from loading this api
  def template_api(name, root, options)
    return {} if options[name].nil?
    assigns = get_assigns(options[name])
    require 'pp'
    info = TemplateInfo.new(root, assigns, options[:input])
    template(info, options[:output], name.to_s)
    assigns
  end

private

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
    Templater.new(info, dirs).template(name, output, suffix)
  end
end

#!/usr/bin/env ruby
# Liquid based templating for the Fineo API
# Outputs the following:
#    - stream api
#    - batch api
#    - combined API (for documentation)

# include the "src/lib" directory
File.expand_path(File.join(__dir__, "lib")).tap {|pwd|
  $LOAD_PATH.unshift(pwd) unless $LOAD_PATH.include?(pwd)
}

require 'liquid'
require 'ostruct'
require 'templater'

api = {}
api["title"] = "fineo-ingest"
api["host"] = "ingest.fineo.io"
api["version"] = "v1"
assigns = {"api" => api}

current = File.dirname(__FILE__)
input = File.join(current, "input")
output_dir = File.join(current, "..")

# just the streaming

output = File.join(output_dir, "stream")
templater = Templater.new(output, "swagger-integrations,authorizers.json", input, ["stream"])
templater.template(assigns.dup())

# just the batch

output = File.join(output_dir, "batch")
templater = Templater.new(output, "swagger-integrations,authorizers.json", input, ["batch"])
templater.template(assigns.dup())

# combined, for the documentation

output = File.join(output_dir, "documentation")
templater = Templater.new(output, "swagger-.json", input, ["stream", "batch"])
templater.template(assigns.dup())

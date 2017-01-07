
require 'templates'

class TemplateInfo
  include Templates

  attr_reader :input, :includes, :definitions, :assigned, :root

  def initialize(root, assigned, input)
     @input = input
     @root = root
     @assigned = assigned
     @includes = load_definitions(File.join(input, Templates::INCLUDES))
     @definitions = load_definitions(File.join(input, Templates::DEFINITIONS))
  end
end

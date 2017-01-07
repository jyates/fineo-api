
require 'liquid'
require 'templates'

class DirBuilder
  include Templates

  def initialize(dir)
    @dir = dir
    @parent = File.split(@dir).last
  end

  def build(includes, definitions)
    includes["parent"] = @parent
    procdir(@dir, definitions, includes)
  end

private

  def procdir(dirname, definitions, includes)
    dirs = [];
    files = []
    Dir.foreach(dirname){|file|
      next if file == '.' or file == '..'
      dirpath = dirname + '/' + file
      if File.directory?(dirpath)
        if file == Templates::INCLUDES
          includes.merge!(load_definitions(dirpath))
        elsif file == Templates::DEFINITIONS
          definitions.merge!(load_definitions(dirpath))
        else
          dirs << dirpath
        end
      else
        files << dirpath
      end
    }

    paths = {}
    dirs.each{|dir|
      paths.merge! procdir(dir, definitions, includes)
    }

    # just read in each file, to be templated later
    files.each{|file|
      paths[file] = File.read(file);
    }
    return paths
  end
end

require "hound/tools/template"
require "hound/tools/hound_yml"
require "hound/tools/hound_overrides"

module Hound
  module Tools
    class MergedYml
      include Template

      def initialize
        @todo_file = '.rubocop_todo.yml'

        # NOTE: should be named. .rubocop.yml to prevent RuboCop from traversing
        super('.hound/.rubocop.yml')
      end

      def generate
        s = StringIO.new
        s.write(<<EOS)
# This is a file generated by `hound-tools`
#
# We don't include .hound/defaults.yml, because Hound has internally
# loaded them at this point
#
EOS
        [HoundOverrides.new.filename, @todo_file].each do |filename|
          s.puts "# ---------------------------------"
          s.puts "# #{filename}"
          s.puts "# ---------------------------------"
          s.puts IO.read(filename)
        end
        Pathname.new(filename).dirname.mkpath
        output_file = HoundYml.new.rubocop_filename
        IO.write(output_file, s.string)

        $stdout.puts "#{output_file} (regenerated)"
      end
    end
  end
end

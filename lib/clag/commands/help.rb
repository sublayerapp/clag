require 'clag'

module Clag
  module Commands
    class Help < Clag::Command
      def call(args, _name)
        puts CLI::UI.fmt("{{bold:Available commands}}")
        puts ""

        Clag::Commands::Registry.resolved_commands.each do |name, klass|
          next if name == "help"
          puts CLI::UI.fmt("{{command:#{Clag::TOOL_NAME} #{name}}}")

          if help = klass.help
            puts CLI::UI.fmt(help)
          end

          puts ""
        end
      end
    end
  end
end

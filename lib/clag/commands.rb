require 'clag'

module Clag
  module Commands
    Registry = CLI::Kit::CommandRegistry.new(default: 'help')

    def self.register(const, cmd, path)
      autoload(const, path)
      Registry.add(->() { const_get(const) }, cmd)
    end

    register :Generate, 'g', 'clag/commands/generate'
    register :Help, 'help', 'clag/commands/help'
  end
end

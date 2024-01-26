require 'clag'

module Clag
  module EntryPoint
    def self.call(args)
      cmd, command_name, args = Clag::Resolver.call(args)

      Clag::Executor.call(cmd, command_name, args)
    end
  end
end

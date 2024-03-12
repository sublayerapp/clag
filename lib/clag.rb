require 'cli/ui'
require 'cli/kit'
require "sublayer"

CLI::UI::StdoutRouter.enable

module Clag
  TOOL_NAME = 'clag'
  ROOT      = File.expand_path('../..', __FILE__)
  LOG_FILE  = '/tmp/clag.log'

  autoload(:EntryPoint, 'clag/entry_point')
  autoload(:Commands,   'clag/commands')
  autoload(:Generators, 'clag/generators/')

  Config = CLI::Kit::Config.new(tool_name: TOOL_NAME)
  Command = CLI::Kit::BaseCommand

  Executor = CLI::Kit::Executor.new(log_file: LOG_FILE)
  Resolver = CLI::Kit::Resolver.new(
    tool_name: TOOL_NAME,
    command_registry: Clag::Commands::Registry
  )

  ErrorHandler = CLI::Kit::ErrorHandler.new(log_file: LOG_FILE)
end

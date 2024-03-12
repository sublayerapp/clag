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
  load 'clag/generators/command_line_command_generator.rb'

  Config = CLI::Kit::Config.new(tool_name: TOOL_NAME)
  Command = CLI::Kit::BaseCommand

  Executor = CLI::Kit::Executor.new(log_file: LOG_FILE)
  Resolver = CLI::Kit::Resolver.new(
    tool_name: TOOL_NAME,
    command_registry: Clag::Commands::Registry
  )

  ErrorHandler = CLI::Kit::ErrorHandler.new(log_file: LOG_FILE)

  case ENV["CLAG_LLM"]
  when "gemini"
    Sublayer.configuration.ai_provider = Sublayer::Providers::Gemini
    Sublayer.configuration.ai_model = "gemini-pro"
  when "claude"
    Sublayer.configuration.ai_provider = Sublayer::Providers::Claude
    Sublayer.configuration.ai_model ="claude-3-opus-20240229"
  when "groq"
    Sublayer.configuration.ai_provider = Sublayer::Providers::Groq
    Sublayer.configuration.ai_model = "mixtral-8x7b-32768"
  when "local"
    Sublayer.configuration.ai_provider = Sublayer::Providers::Local
    Sublayer.configuration.ai_model = "LLaMA_CPP"
  else
    Sublayer.configuration.ai_provider = Sublayer::Providers::OpenAI
    Sublayer.configuration.ai_model = "gpt-4-turbo-preview"
  end
end

require 'clag'
require "clipboard"

module Clag
  module Commands
    class Generate < Clag::Command
      def call(args, _name)
        input = args.join(" ")

        if ENV['OPENAI_API_KEY'].nil?
          puts CLI::UI.fmt("{{red:OPENAI_API_KEY is not set. Please set it before continuing.}}")
          return
        end

        if input.nil?
          puts "Please provide input to generate options."
          return
        end

        results = Sublayer::Agents::GenerateCommandLineCommandAgent.new(description: input).execute

        if results == 'unknown'
          puts CLI::UI.fmt("{{yellow:Unable to generate command. Please try again or provide more information.}}")
          return
        end

        Clipboard.copy(results)
        puts "\e[1;32m#{results}\e[0m\nCopied to clipboard."
      end

      def self.help
        "Generate a command-line command and store it in the clipboard. \nUsage: {{command:#{Clag::TOOL_NAME} g \"the command you want to generate\"}}"
      end
    end
  end
end

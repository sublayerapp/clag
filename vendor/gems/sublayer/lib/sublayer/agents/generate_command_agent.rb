module Sublayer
  module Agents
    class GenerateCommandLineCommandAgent
      include Sublayer::Capabilities::LLMAssistance
      include Sublayer::Capabilities::HumanAssistance

      attr_reader :description, :results

      llm_result_format type: :single_string,
        name: "command",
        description: "The command line command for the user to run or 'unknown'"

      def initialize(description:)
        @description = description
      end

      def execute
        @results = llm_generate
      end

      def prompt
        <<-PROMPT
        You are an expert in command line operations.

        You are tasked with finding or crafting a command line command to achieve the following:

        #{description}

        Considering best practices, what should be run on the command line to achieve this.

        If no command is possible, respond with 'unknown'

        PROMPT
      end
    end
  end
end

class CommandLineCommandGenerator < Sublayer::Generators::Base
  llm_result_format type: :single_string,
    name: "command",
    description: "The command line command for the user to run or 'unknown'"

  def initialize(description:)
    @description = description
  end

  def generate
    super
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

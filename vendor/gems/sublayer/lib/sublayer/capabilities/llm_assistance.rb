require "openai"
require "pry"
require "httparty"
require "nokogiri"

module Sublayer
  module Capabilities
    module LLMAssistance
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def llm_result_format(type:, name:, description:)
          output_function = Sublayer::Components::OutputFunction.create(type: type, name: name, description: description)
          const_set(:OUTPUT_FUNCTION, output_function)
        end
      end

      def llm_generate
        case ENV["CLAG_LLM"]
        when "gemini"
          generate_with_gemini
        when "claude"
          generate_with_claude
        when "groq"
          generate_with_groq
        else
          generate_with_openai
        end
      end

      private

      def generate_with_groq
        system_prompt = <<-PROMPT
        In this environment you have access to a set of tools you can use to answer the user's question.

        You may call them like this:
        <function_calls>
        <invoke>
          <tool_name>$TOOL_NAME</tool_name>
          <parameters>
          <command>value</command>
          ...
          </parameters>
        </invoke>
        </function_calls>

        Here are the tools available:
        <tools>
        #{self.class::OUTPUT_FUNCTION.to_xml}
        </tools>

        Respond only with valid xml.
        The entire response should be wrapped in a <response> tag.
        Any additional information not inside a tool call should go in a <scratch> tag.
        PROMPT

        response = HTTParty.post(
          "https://api.groq.com/openai/v1/chat/completions",
          headers: {
            "Authorization": "Bearer #{ENV["GROQ_API_KEY"]}",
            "Content-Type": "application/json"
          },
          body: {
            "messages": [{"role": "user", "content": "#{system_prompt}\n#{prompt}"}],
            "model": "mixtral-8x7b-32768"
          }.to_json
        )

        text_containing_xml = JSON.parse(response.body).dig("choices", 0, "message", "content")
        xml = text_containing_xml.match(/\<response\>(.*?)\<\/response\>/m).to_s
        response_xml = Nokogiri::XML(xml)
        function_output = response_xml.at_xpath("//response/function_calls/invoke/parameters/command").children.to_s

        return function_output
      end

      def generate_with_claude
        system_prompt = <<-PROMPT
        In this environment you have access to a set of tools you can use to answer the user's question.

        You may call them like this:
        <function_calls>
        <invoke>
          <tool_name>$TOOL_NAME</tool_name>
          <parameters>
          <$PARAMETER_NAME>$PARAMETER_VALUE</$PARAMETER_NAME>
          ...
          </parameters>
        </invoke>
        </function_calls>

        Here are the tools available:
        <tools>
        #{self.class::OUTPUT_FUNCTION.to_xml}
        </tools>

        Respond only with valid xml. The entire response should be wrapped in a <response> tag. Any additional information not inside a tool call should go in a <scratch> tag.
        PROMPT

        response = HTTParty.post(
          "https://api.anthropic.com/v1/messages",
          headers: {
            "x-api-key": ENV["ANTHROPIC_API_KEY"],
            "anthropic-version": "2023-06-01",
            "content-type": "application/json"
          },
          body: {
            model: "claude-3-opus-20240229",
            max_tokens: 1337,
            system: system_prompt,
            messages: [
              { "role": "user", "content": prompt }
            ]
          }.to_json
        )

        # raise an error if the response is not a 200
        raise "Error generating with Claude, error: #{response.body}" unless response.code == 200

        text_containing_xml = JSON.parse(response.body).dig("content", 0, "text")

        # Extract the xml from the respons contained in <response> tags the content of the string looksl ike this:
        xml = text_containing_xml.match(/\<response\>(.*?)\<\/response\>/m).to_s

        # Parse the xml and extract the response
        response_xml = Nokogiri::XML(xml)

        # Extract the response from the xml
        function_output = response_xml.at_xpath("//response/function_calls/invoke/parameters/command").children.to_s

        return function_output
      end

      def generate_with_gemini
        gemini_prompt = adapt_prompt_for_gemini

        response = HTTParty.post("https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=#{ENV['GEMINI_API_KEY']}", body: gemini_prompt.to_json, headers: { 'Content-Type' => 'application/json' })

        function_output = extract_function_output_from_gemini_response(response)

        return function_output
      end

      def adapt_prompt_for_gemini
        return({ tools: { function_declarations: [ self.class::OUTPUT_FUNCTION.to_hash ] }, contents:  { role: "user", parts: { text: prompt } }  })
      end

      def extract_function_output_from_gemini_response(response)
        candidates = response.dig('candidates')
        if candidates && candidates.size > 0
          content = candidates[0].dig('content')
          if content && content['parts'] && content['parts'].size > 0
            part = content['parts'][0]

            # Check if the part contains a function call
            if part.key?('functionCall')
              function_name = part['functionCall']['name']
              args = part['functionCall']['args']

              # Assuming the agent expects a single string parameter:
              if args && args.key?(self.class::OUTPUT_FUNCTION.name)
                return args[self.class::OUTPUT_FUNCTION.name]
              end
            else
              # If it's not a function call, check for a direct string response
              return part['text'] if part.key?('text')
            end
          end
        end
      end

      def generate_with_openai
        client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

        response = client.chat(
          parameters: {
            model: "gpt-4-turbo-preview",
            messages: [
              {
                "role": "user",
                "content": prompt
              }
            ],
            function_call: { name: self.class::OUTPUT_FUNCTION.name },
            functions: [
              self.class::OUTPUT_FUNCTION.to_hash
            ]
          }
        )

        message = response.dig("choices", 0, "message")
        raise "No function called" unless message["function_call"]

        function_name = message.dig("function_call", self.class::OUTPUT_FUNCTION.name)
        args_from_llm = message.dig("function_call", "arguments")
        JSON.parse(args_from_llm)[self.class::OUTPUT_FUNCTION.name]
      end
    end
  end
end

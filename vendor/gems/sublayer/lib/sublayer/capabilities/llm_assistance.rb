require "openai"
require "httparty"

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
        if ENV["CLAG_LLM"] == "gemini"
          generate_with_gemini
        else
          generate_with_openai
        end
      end

      private
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

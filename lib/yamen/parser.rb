module Yamen
  class Parser
    def initialize(core_rules, user_rules)
      @core_rules = core_rules
      @user_rules = user_rules
    end

    # Read in a JSON/Hash definition in format, and return a Rule object
    #
    #     {
    #       "rule": "And",
    #       "params": {
    #         conditions: [
    #           {
    #             "rule": "Number",
    #             "params": { "larger_than": "100" }
    #           }
    #         ]
    #       }
    #    }
    #
    def read(json)
      rule = json.fetch('rule')

      if core_class = @core_rules[rule]
        conditions = json.fetch('params', {}).fetch('conditions', [])
        conditions = conditions.map { |param| read(param) }
        core_class.new('conditions' => conditions)
      elsif user_class = @user_rules[rule]
        user_class.new(json.fetch('params'))
      else
        raise ArgumentError.new("Undefined Rule: #{rule}")
      end
    end

    # Validate a JSON definition, and return errors or nil
    def validate(json)
      errors = ValidationErrors.new

      if validate(json, errors)
        errors
      else
        nil
      end
    end

    private

  end

  class ValidationErrors
  end
end

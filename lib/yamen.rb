require "yamen/version"

module Yamen
  class Governor
    attr_reader :junction_module, :junction_rules, :user_module, :user_rules

    def initialize(junction_rule_module, user_rule_module)
      @junction_module = junction_rule_module
      @junction_rules = junction_rule_module.constants
      @user_module = user_rule_module
      @user_rules = user_rule_module.constants
    end

    # TODO
    def user_rules_config
      @user_rules.map do |rule|
        {
          type: rule,
          args: @user_module.const_get(rule).requirements
        }
      end
    end

    def parser
      @parser ||= Parser.new(@junction_module, @user_module)
    end
  end

  class Parser
    def initialize(junction_rule_module, user_rule_module)
      @junction_module = junction_rule_module
      @junction_rules = junction_rule_module.constants
      @user_module = user_rule_module
      @user_rules = user_rule_module.constants
    end

    # read a JSON hash, and return the root Rule object
    def read(json_rule)
      read_rule(json_rule)
    end

    # validate a JSON hash, and return errors or nil
    def validate(json_rule)
      errors = []
      validate_rule(json_rule, errors)
      errors
    end

    private

    def validate_rule(rule, errors)
      # TODO implement
    end

    def read_rule(rule)
      type = rule['type'].to_sym # TODO .capitalize.to_sym

      if @junction_rules.include?(type)
        rule_class = @junction_module.const_get(type)
        conditions = rule['args'].map { |arg| read_rule(arg) }
        rule_class.new(conditions)
      elsif @user_rules.include?(type)
        rule_class = @user_module.const_get(type)
        rule_class.new(rule['args'])
      else
        raise ArgumentError.new("Invalid Rule: #{type}")
      end
    end
  end

  class BaseRule
  end

  module BooleanRule
    class And
      def initialize(conditions)
        @conditions = conditions
      end

      def eval(facts)
        # TODO record failed condition name and facts
        @conditions.all? { |condition| condition.eval(facts) == true }
      end

      # TODO better to_s for debugging
    end

    class Or
      def initialize(conditions)
        @conditions = conditions
      end

      def eval(facts)
        # TODO record failed condition name and facts
        @conditions.any? { |condition| condition.eval(facts) == true }
      end

      # TODO better to_s for debugging
    end
  end

  module MathRule
    class Plus
      def initialize(conditions)
        @conditions = conditions
      end

      def eval(facts)
        @conditions.all? { |condition| condition.eval(facts) == true }
      end

      # TODO better to_s for debugging
    end

    class Minus
      def initialize(conditions)
        @conditions = conditions
      end

      def eval(facts)
        @conditions.any? { |condition| condition.eval(facts) == true }
      end

      # TODO better to_s for debugging
    end
  end
end

require 'json'

require 'yamen/version'
require 'yamen/parser'
require 'yamen/rule'
require 'yamen/rules/boolean'

module Yamen
  class Governor
    attr_reader :core_rules, :user_rules, :authorized_rule

    def initialize(core_rule_modules, user_rule_modules)
      @core_rules = {}
      Array(core_rule_modules).each do |rule_module|
        source_module_rules(rule_module, @core_rules)
      end

      @user_rules = {}
      Array(user_rule_modules).each do |rule_module|
        source_module_rules(rule_module, @user_rules)
      end
    end

    def read(json_or_hash)
      hash = if json_or_hash.is_a? String
               JSON.parse(json_or_hash)
             else
               json_or_hash
             end

      @authorized_rule = parser.read(hash)
    end

    def decision(facts)
      @authorized_rule.decision(facts)
    end

    private

    def parser
      @parser ||= Parser.new(@core_rules, @user_rules)
    end

    def source_module_rules(rule_module, rules)
      rule_module.constants.each_with_object(rules) do |constant, memo|
        const = rule_module.const_get(constant)
        if const.is_a?(Class) && const.ancestors.include?(Yamen::Rule)
          memo[constant.to_s] = const
        end
      end
    end
  end

  class BooleanGovernor < Governor
    def initialize(rule_modules)
      super(Yamen::Rules::Boolean, rule_modules)
    end
  end
end

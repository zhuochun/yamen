require 'yamen/rule'
require 'yamen/type'

module Yamen::Rules
  module Boolean
    class And < Yamen::Rule
      parameter :conditions, Yamen::ArrayType
      parameter :fast_exit, Yamen::BooleanType, default: true

      def decision(facts)
        result = true
        errors = []

        conditions.each do |condition|
          decision = condition.decision(facts)

          result &= decision[0]
          errors += Array(decision[1]).compact

          break if !result && fast_exit
        end

        [result, errors]
      end
    end

    class Or < Yamen::Rule
      parameter :conditions, Yamen::ArrayType
      parameter :fast_exit, Yamen::BooleanType, default: true

      def decision(facts)
        result = false
        errors = []

        conditions.each do |condition|
          decision = condition.decision(facts)

          result |= decision[0]
          errors += Array(decision[1]).compact

          break if result && fast_exit
        end

        [result, errors]
      end
    end
  end
end

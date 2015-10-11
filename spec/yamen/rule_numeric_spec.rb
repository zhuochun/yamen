require 'spec_helper'

module SimpleRule
  class Number < Yamen::Rule
    parameter :operation, Yamen::StringType, enum:
      %w(larger_than larger_than_or_equal_to smaller_than smaller_than_or_equal_to)
    parameter :value, Yamen::FloatType

    def decision(fact)
      return [false, %("#{fact}" is not a numeric)] unless fact.is_a?(Numeric)

      result = case operation
               when 'larger_than'
                 fact > value
               when 'larger_than_or_equal_to'
                 fact >= value
               when 'smaller_than'
                 fact < value
               when 'smaller_than_or_equal_to'
                 fact <= value
               end

      result ? [true, nil] : [false, %(#{fact} is not #{operation} #{value})]
    end
  end
end

describe SimpleRule::Number do
  let(:rule) { SimpleRule::Number.new('operation' => 'larger_than', 'value' => '100') }

  it 'defines parameters' do
    expect(rule.operation).to eq('larger_than')
    expect(rule.value).to eq(100)
  end

  it 'valid? string => false' do
    decision = rule.decision('string')

    expect(decision[0]).to be(false)
    expect(decision[1]).to eq('"string" is not a numeric')
  end

  it 'valid? 50.05 => false' do
    decision = rule.decision(50.05)

    expect(decision[0]).to be(false)
    expect(decision[1]).to eq('50.05 is not larger_than 100.0')
  end

  it 'valid? 100.01 => true' do
    decision = rule.decision(100.01)

    expect(decision[0]).to be(true)
    expect(decision[1]).to be_nil
  end
end

describe Yamen::BooleanGovernor do
  let(:governor) { Yamen::BooleanGovernor.new(SimpleRule) }

  it 'read rules and decision' do
    governor.read <<-RULE
      {
        "rule": "Number",
        "params": {
          "operation": "larger_than_or_equal_to",
          "value": "99.99"
        }
      }
    RULE

    decision = governor.decision(100)
    expect(decision[0]).to be(true)
    expect(decision[1]).to be_nil

    decision = governor.decision(99)
    expect(decision[0]).to be(false)
    expect(decision[1]).to eq('99 is not larger_than_or_equal_to 99.99')
  end
end

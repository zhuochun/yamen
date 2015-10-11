require 'spec_helper'

module Yamen::Rules
  true_condition = Object.new
  def true_condition.decision(*args); [true, nil]; end

  false_condition = Object.new
  def false_condition.decision(*args); [false, 'error']; end

  describe Boolean::And do
    it 'returns true when no conditions provided' do
      rule = described_class.new('conditions' => [])
      result = rule.decision(nil)

      expect(result[0]).to be(true)
      expect(result[1]).to match([])
    end

    it 'returns true if all conditions decision to true' do
      rule = described_class.new('conditions' => [true_condition, true_condition])
      result = rule.decision(nil)

      expect(result[0]).to be(true)
      expect(result[1]).to match([])
    end

    it 'returns false if one condition decision to false' do
      rule = described_class.new('conditions' => [true_condition, false_condition])
      result = rule.decision(nil)

      expect(result[0]).to be(false)
      expect(result[1]).to match(['error'])
    end

    it 'returns false if some conditions decision to false and no fast_exit' do
      rule = described_class.new('conditions' => [false_condition, true_condition, false_condition],
                                 'fast_exit' => false)
      result = rule.decision(nil)

      expect(result[0]).to be(false)
      expect(result[1]).to match(['error', 'error'])
    end
  end

  describe Boolean::Or do
    it 'returns false when no conditions provided' do
      rule = described_class.new('conditions' => [])
      result = rule.decision(nil)

      expect(result[0]).to be(false)
      expect(result[1]).to match([])
    end

    it 'returns true if one condition decision to true' do
      rule = described_class.new('conditions' => [false_condition, true_condition])
      result = rule.decision(nil)

      expect(result[0]).to be(true)
      expect(result[1]).to match(['error'])
    end

    it 'returns false if all conditions decision to false' do
      rule = described_class.new('conditions' => [false_condition, false_condition])
      result = rule.decision(nil)

      expect(result[0]).to be(false)
      expect(result[1]).to match(['error', 'error'])
    end

    it 'returns true if some conditions decision to false and no fast_exit' do
      rule = described_class.new('conditions' => [false_condition, true_condition, false_condition],
                                 'fast_exit' => false)
      result = rule.decision(nil)

      expect(result[0]).to be(true)
      expect(result[1]).to match(['error', 'error'])
    end
  end
end

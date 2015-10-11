require 'spec_helper'

class RespondTo < Yamen::Rule
  parameter :method_name, Yamen::StringType

  def decision(facts)
    if facts.respond_to?(method_name.to_sym)
      [true, nil]
    else
      [false, "does not respond_to? :#{@method_name}"]
    end
  end
end

describe Yamen::Rule do
  describe '#parameter' do
    it 'returns parameters' do
      respond_to = RespondTo.new
      expect(respond_to.parameters).to eq(RespondTo.parameters)
    end
  end

  describe '#valid?' do
    it 'is not valid when parameter is not provided' do
      respond_to = RespondTo.new
      expect(respond_to.valid?).to be(false)
      expect(respond_to.errors).not_to be_nil
    end

    it 'is valid when parameter is casted' do
      respond_to = RespondTo.new('method_name' => 1)
      expect(respond_to.valid?).to be(true)
      expect(respond_to.errors).to be_nil
    end

    it 'is valid' do
      respond_to = RespondTo.new('method_name' => 'to_s')
      expect(respond_to.valid?).to be(true)
      expect(respond_to.errors).to be_nil
    end
  end

  describe '#method_name' do
    it 'is dynamically defined' do
      respond_to = RespondTo.new
      expect(respond_to.respond_to?(:method_name)).to be(true)
    end

    it 'raises an error if params not provided' do
      respond_to = RespondTo.new
      expect { respond_to.method_name }.to raise_exception(KeyError)
    end

    it 'returns parameter' do
      respond_to = RespondTo.new('method_name' => 'to_s')
      expect(respond_to.method_name).to eq('to_s')
    end
  end

  describe '#decision' do
    let(:respond_to) { RespondTo.new('method_name' => 'to_sym') }

    it 'returns true' do
      result = respond_to.decision('string')
      expect(result[0]).to be(true)
    end

    it 'returns false' do
      result = respond_to.decision(123)
      expect(result[0]).to be(false)
    end
  end
end

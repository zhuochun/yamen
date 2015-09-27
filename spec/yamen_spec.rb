require 'spec_helper'

module UserRule
  class PickUpTime < Yamen::BaseRule
    # TODO defined in BaseRule, or use ActiveRecord validates
    # require_config :weekday, :intger, range: 0..6
    # require_config :startTime, :string, format: /\d{2}:\d{2}/
    # require_config :endTime, :string, format: /\d{2}:\d{2}/

    def initialize(args)
      @weekday = args.fetch('weekday')
      @startTime = args.fetch('startTime')
      @endTime = args.fetch('endTime')
    end

    def eval(facts)
      facts[:booking].pick_up_time.wday == @weekday
    end
  end

  class PickUpLocation < Yamen::BaseRule
    def initialize(args)
      @polygon = args.fetch('polygon') # TODO convert polygon
    end

    def eval(facts)
      @polygon.cover?(facts[:booking].pick_up_latitude, facts[:booking].pick_up_longitude)
    end
  end
end

describe Yamen do
  describe Yamen::Governor do
    it 'return all the rules' do
      governor = Yamen::Governor.new(Yamen::BooleanRule, UserRule)
      expect(governor.junction_rules).to match_array([:And, :Or])
      expect(governor.user_rules).to match_array([:PickUpTime, :PickUpLocation])
    end

    it 'return all the rules in details' do
      # TODO pending implement
    end
  end

  describe Yamen::Parser do
    it 'parse and correctly' do
      parser = Yamen::Parser.new(Yamen::BooleanRule, TrueClass)
      root = parser.read({ 'type' => 'And', 'args' => [] })
      expect(root).to be_an_instance_of(Yamen::BooleanRule::And)
      expect(root.eval('anything')).to be(true)
    end

    it 'parse or correctly' do
      parser = Yamen::Parser.new(Yamen::BooleanRule, TrueClass)
      root = parser.read({ 'type' => 'Or', 'args' => [] })
      expect(root).to be_an_instance_of(Yamen::BooleanRule::Or)
      expect(root.eval('anything')).to be(false)
    end

    it 'parse or + pickUpTime correctly' do
      parser = Yamen::Parser.new(Yamen::BooleanRule, UserRule)
      root = parser.read({
        'type' => 'Or', 'args' => [
          { 'type' => 'PickUpTime', 'args' => { 'weekday' => 1, 'startTime' => 0, 'endTime' => 24 } },
          { 'type' => 'PickUpTime', 'args' => { 'weekday' => 2, 'startTime' => 0, 'endTime' => 24 } }
        ]
      })
      expect(root).to be_an_instance_of(Yamen::BooleanRule::Or)

      Booking = Struct.new(:pick_up_time)

      facts = { booking: Booking.new(Time.parse('2015-09-24 02:49:53 +0800')) }
      expect(root.eval(facts)).to be(false)

      facts = { booking: Booking.new(Time.parse('2015-09-21 02:49:53 +0800')) }
      expect(root.eval(facts)).to be(true)
    end
  end
end

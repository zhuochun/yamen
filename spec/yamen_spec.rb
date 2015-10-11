require 'spec_helper'

Booking = Struct.new(:pick_up_time, :drop_off_time)

module UserRule
  class TimeInRange < Yamen::Rule
    HOUR_IN_SECONDS = 3600
    MINUTE_IN_SECONDS = 60

    parameter :method, Yamen::StringType, enum: [nil, 'pick_up_time', 'drop_off_time']
    parameter :weekday, Yamen::StringType, enum: Date::DAYNAMES
    parameter :start_time, Yamen::StringType, from: :startTime, validate: ->(p) { p =~ /\d{2}:\d{2}/ }
    parameter :end_time, Yamen::StringType, from: :endTime, validate: ->(p) { p =~ /\d{2}:\d{2}/ }

    def decision(facts)
      unless facts.respond_to?(method)
        return [false, "does not respond_to? #{method}"]
      end

      time = facts.send(method)

      unless Date::DAYNAMES[time.wday] == weekday
        return [false, "#{time} is not a #{weekday}"]
      end

      unless time_in_range?(time)
        return [false, "#{time} is not between #{start_time} - #{end_time}"]
      end

      return [true, nil]
    end

    private

    def time_in_range?(time)
      (time_in_seconds(start_time)..time_in_seconds(end_time)).cover?(
        seconds_from_midnight(time.hour, time.minute, time.second))
    end

    def time_in_seconds(time)
      hour, minutes = time.split(':').map(&:to_i)
      seconds_from_midnight(hour, minutes)
    end

    def seconds_from_midnight(hour, minutes, seconds = 0)
      hour * HOUR_IN_SECONDS + minutes * MINUTE_IN_SECONDS + seconds
    end
  end
end

describe Yamen::BooleanGovernor do
  let(:governor) { Yamen::BooleanGovernor.new(UserRule) }

  it 'return all the rules' do
    expect(governor.core_rules.keys).to match_array(['And', 'Or'])
    expect(governor.user_rules.keys).to match_array(['TimeInRange'])
  end

  it 'return all the rules in details' do
    # TODO pending implement
  end

  context 'An OR[TimeInRange, TimeInRange] rule' do
    before do
      governor.read <<-RULES
        {
          "rule": "Or",
          "params": {
            "conditions": [
              {
                "rule": "TimeInRange",
                "params": {
                  "method": "pick_up_time",
                  "weekday": "Monday",
                  "startTime": "08:00",
                  "endTime": "10:00"
                }
              },
              {
                "rule": "TimeInRange",
                "params": {
                  "method": "pick_up_time",
                  "weekday": "Monday",
                  "startTime": "17:30",
                  "endTime": "21:00"
                }
              }
            ]
          }
        }
      RULES
    end

    it 'has authorized_rule' do
      expect(governor.authorized_rule).not_to be_nil
      expect(governor.authorized_rule).to be_an_instance_of(Yamen::Rules::Boolean::Or)
    end

    it 'returns false when pick_up_time is not on Monday' do
      booking = Booking.new(DateTime.parse('2015-10-09 11:00 +0800'),
                            DateTime.parse('2015-10-09 11:50 +0800'))

      decision = governor.decision(booking)

      expect(decision[0]).to be(false)
    end

    it 'returns true when pick_up_time is on Monday morning' do
      booking = Booking.new(DateTime.parse('2015-10-19 08:30 +0800'),
                            DateTime.parse('2015-10-19 08:50 +0800'))

      decision = governor.decision(booking)

      expect(decision[0]).to be(true)
    end

    it 'returns true when pick_up_time is on Monday morning' do
      booking = Booking.new(DateTime.parse('2015-10-05 18:30 +0800'),
                            DateTime.parse('2015-10-05 18:35 +0800'))

      decision = governor.decision(booking)

      expect(decision[0]).to be(true)
    end
  end
end

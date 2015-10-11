module Yamen
  # An abstract rule
  #
  # A minimal implement could be:
  #
  #   class RespondToRule < Yamen::Rule
  #     parameter :method_name, Yamen::StringType
  #
  #     def decision(facts)
  #       facts.respond_to?(@method_name.to_sym)
  #     end
  #   end
  #
  #   rule = RespondToRule.new('method_name' => 'split')
  #   rule.decision('string') # => [true, nil]
  #   rule.decision(100) # => [false, '100 does not respond to :split']
  #
  #   rule = RespondToRule.new('method_name' => nil)
  #   rule.valid? # => false
  #   rule.errors # => { method_name: ['is expected to be defined',
  #                                    'is expected to be a String'] }
  #
  class Rule
    # return the defined parameters
    def self.parameters
      @parameters ||= {}
    end

    # define parameter with optional options[:from, :default, :validate]
    def self.parameter(param_name, type, options = {})
      key = options.fetch(:from, param_name).to_s

      define_method param_name do |&block|
        begin
          value = if options.has_key?(:default)
                    @_params.fetch(key, options[:default])
                  else
                    @_params.fetch(key)
                  end

          value = type.call(value)

          if options.has_key?(:as)
            value.send(options[:as])
          else
            value
          end
        rescue Exception => err
          return block.call(nil, err) if block
          raise err
        end
      end

      parameters[param_name] = [type, options]
    end

    def initialize(params = {})
      @_params = params
    end

    def parameters
      self.class.parameters
    end

    def valid?
      validate.empty?
    end

    def errors
      validate.empty? ? nil : @errors
    end

    private

    def validate
      return @errors if defined? @errors

      @errors = []
      parameters.each_key do |param|
        send(param) do |raw, err|
          @errors << "[#{self.class.name}] #{err.message}"
        end
      end
      @errors
    end
  end
end

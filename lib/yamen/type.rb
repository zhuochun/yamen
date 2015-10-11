module Yamen
  StringType  = ->(input) { String(input) }
  BooleanType = ->(input) { input == true || input == 1 || input == 'true'.freeze }
  IntegerType = ->(input) { Integer(input) }
  FloatType   = ->(input) { Float(input) }
  ArrayType   = ->(input) { Array(input) }
end

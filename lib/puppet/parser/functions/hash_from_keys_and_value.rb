module Puppet::Parser::Functions
  newfunction(:hash_from_keys_and_value, :type => :rvalue, :doc => <<-EOS
 Takes a list of keys and a single value and creates a hash.

 * Example:*

     hash_from_keys_and_value(['key1', 'key2'], 'value')

 Would result in:

     {'key1' => 'value', 'key2', 'value'}
     EOS
  ) do |arguments|
    
    raise(Puppet::ParseError, "hash_from_keys_and_value(): Wrong number of " +
      " arguments given (#{arguments.size} for 2)") if arguments.size < 2

    keys = arguments[0]
    value = arguments[1]

    unless keys.is_a?(Array)
      raise(Puppet::ParseError, "hash_from_keys_and_value(): keys must be an " +
        "array.")
    end

    result = { }
    keys.each do |key|
      result[key] = value
    end

    return result
  end
end

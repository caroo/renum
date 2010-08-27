require 'forwardable'
require 'set'

module Renum

  # This is the superclass of all enumeration classes. 
  # An enumeration class is Enumerable over its values and exposes them by numeric index via [].
  # Values are also comparable, sorting into the order in which they're declared.
  class EnumeratedValue

    class << self
      include Enumerable
      extend Forwardable

      def_delegators :values, :each, :[]

      # Returns an array of values in the order they're declared.
      def values
        @values ||= []
      end

      alias all values

      class Field < Struct.new('Field', :name, :options, :block)
        def default?
          options.key?(:default)
        end

        def default
          options[:default]
        end

        def block?
          !!block
        end

        def default_value obj, options
          field_value = options[name]
          if field_value.nil?
            if default?
              default_value = default
            elsif block?
              default_value = block[obj]
            end
          else
            field_value
          end
        end

        def to_s
          name.to_s
        end

        def inspect
          "#<#{self.class}: #{self} #{options.inspect}>"
        end
      end

      def fields
        @fields ||= Set.new
      end

      def field(name, options = {}, &block)
        fields << field = Field.new(name.to_sym, options, block)
        instance_eval { attr_reader field.name }
      end

      def with_name name
        values_by_name[name]
      end

      def values_by_name
        @values_by_name ||= values.inject({}) do |memo, value|
          memo[value.name] = value
          memo
        end.freeze
      end

    end

    include Comparable

    attr_reader :name, :index

    def initialize name
      @name = name.to_s.freeze
      @index = self.class.values.size
      self.class.values << self
    end

    def init(*args)
      if Hash === options = args.last
        for field in self.class.fields
          instance_variable_set "@#{field}", field.default_value(self, options)
        end
      end
    end

    # Returns the fully qualified name of the constant referring to this value.
    # Don't override this if you're using Renum with the constantize_attribute 
    # plugin, which relies on this behavior.
    def to_s
      "#{self.class}::#{name}"
    end

    # Sorts enumerated values into the order in which they're declared.
    def <=> other
      index <=> other.index
    end

  end
end

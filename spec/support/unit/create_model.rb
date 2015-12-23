module UnitTests
  class CreateModel
    def self.call(args)
      new(args).call
    end

    DEFAULT_MODEL_NAME = 'Example'
    DEFAULT_ATTRIBUTE_NAME = :attr
    DEFAULT_COLUMN_TYPE = :string

    def initialize(args)
      @args = args
    end

    def call
      model_customizer = lambda do |m|
        m.public_send(validation_name, attribute_name, validation_options)
      end

      model = model_creation_strategy.call(
        model_name,
        columns,
        attribute_name: attribute_name,
        &model_customizer
      )

      _change_value = method(:change_value)

      if model_options.key?(:changing_values_with)
        model.send(:define_method, "#{attribute_name}=") do |value|
          super(_change_value.call(value))
        end
      end

      model
    end

    def model_name
      args.fetch(:model_name, DEFAULT_MODEL_NAME)
    end

    def attribute_name
      args.fetch(:attribute_name, DEFAULT_ATTRIBUTE_NAME)
    end

    protected

    attr_reader :args

    private

    def model_creation_strategy
      args.fetch(:model_creation_strategy)
    end

    def columns
      { column_name => column_type }
    end

    def model_options
      args.fetch(:model_options, {})
    end

    def value_changer
      model_options[:changing_values_with]
    end

    def change_value(value)
      case value_changer
      when Proc
        value_changer.call(value)
      when :next_value
        if value.is_a?(Array)
          value + [value.first.class.new]
        elsif value.respond_to?(:next)
          value.next
        else
          value + 1
        end
      else
        value.public_send(value_changer)
      end
    end

    def column_name
      attribute_name
    end

    def column_type
      args.fetch(:column_type, DEFAULT_COLUMN_TYPE)
    end

    def validation_name
      args.fetch(:validation_name) { map_matcher_name_to_validation_name }
    end

    def validation_options
      args.fetch(:validation_options, {})
    end

    def map_matcher_name_to_validation_name
      matcher_name.to_s.sub('validate', 'validates')
    end

    def matcher_name
      args.fetch(:matcher_name)
    end
  end
end

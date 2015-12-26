module UnitTests
  class CreateModel
    def self.call(args)
      new(args).call
    end

    DEFAULT_MODEL_NAME = 'Example'
    DEFAULT_ATTRIBUTE_NAME = :attr
    DEFAULT_COLUMN_TYPE = :string

    delegate :customize_model, to: :model_creator

    def initialize(args)
      @args = args
      @model_creator = build_model_creator
    end

    def call
      model_creator.call
    end

    def model_name
      args.fetch(:model_name, DEFAULT_MODEL_NAME)
    end

    def attribute_name
      args.fetch(:attribute_name, DEFAULT_ATTRIBUTE_NAME)
    end

    protected

    attr_reader :args, :model_creator

    private

    def build_model_creator
      model_creation_strategy.new(model_name, columns).tap do |model_creator|
        model_creator.customize_model do |model|
          add_validation_to(model)
          possibly_override_attribute_writer_method_for(model)
        end
      end
    end

    def add_validation_to(model)
      if model_options[:custom_validation]
        _attribute_name = attribute_name

        model.send(:define_method, :custom_validation) do
          custom_validation.call(self, _attribute_name)
        end

        model.validate(:custom_validation)
      else
        model.public_send(validation_name, attribute_name, validation_options)
      end
    end

    def possibly_override_attribute_writer_method_for(model)
      if model_options.key?(:changing_values_with)
        _change_value = method(:change_value)

        model.send(:define_method, "#{attribute_name}=") do |value|
          super(_change_value.call(value))
        end
      end
    end

    def change_value(value, _value_changer = value_changer)
      case _value_changer
      when Proc
        _value_changer.call(value)
      when :previous_value
        if value.is_a?(String)
          value[0..-2] + (value[-1].ord - 1).chr
        else
          value - 1
        end
      when :next_value
        if value.is_a?(Array)
          value + [value.first.class.new]
        elsif value.respond_to?(:next)
          value.next
        else
          value + 1
        end
      when :next_next_value
        change_value(change_value(value, :next_value), :next_value)
      when :next_value_or_numeric_value
        if value
          change_value(value, :next_value)
        else
          change_value(value, :numeric_value)
        end
      when :next_value_or_non_numeric_value
        if value
          change_value(value, :next_value)
        else
          change_value(value, :non_numeric_value)
        end
      when :never_falsy
        value || 'something different'
      when :truthy_or_numeric
        value || 1
      when :never_blank
        value.presence || 'something different'
      when :always_nil
        nil
      when :add_character
        value + 'a'
      when :remove_character
        value.chop
      when :numeric_value
        1
      when :non_numeric_value
        'a'
      else
        value.public_send(_value_changer)
      end
    end

    def map_matcher_name_to_validation_name
      matcher_name.to_s.sub('validate', 'validates')
    end

    def model_creation_strategy
      args.fetch(:model_creation_strategy)
    end

    def columns
      { column_name => column_options.merge(type: column_type) }
    end

    def column_name
      attribute_name
    end

    def column_options
      args.fetch(:column_options, {})
    end

    def column_type
      args.fetch(:column_type, DEFAULT_COLUMN_TYPE)
    end

    def model_options
      args.fetch(:model_options, {})
    end

    def value_changer
      model_options[:changing_values_with]
    end

    def validation_name
      args.fetch(:validation_name) { map_matcher_name_to_validation_name }
    end

    def validation_options
      args.fetch(:validation_options, {})
    end

    def matcher_name
      args.fetch(:matcher_name)
    end
  end
end

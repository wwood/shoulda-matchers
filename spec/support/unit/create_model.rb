module UnitTests
  class CreateModel
    def self.call(args)
      new(args).call
    end

    DEFAULT_MODEL_NAME = 'Example'
    DEFAULT_ATTRIBUTE_NAME = :attr
    DEFAULT_COLUMN_TYPE = :string

    def initialize(args, &model_customizer)
      @args = args
      @model_customizer = model_customizer
    end

    def call
      model_creator = model_creation_strategy.new(
        model_name,
        columns,
        attribute_name: attribute_name,
        &model_customizer
      )

      model_creator.customize_model do |model|
        if model_options[:custom_validation]
          _attribute_name = attribute_name

          model.send(:define_method, :custom_validation) do
            custom_validation.call(self, _attribute_name)
          end

          model.validate(:custom_validation)
        else
          model.public_send(validation_name, attribute_name, validation_options)
        end

        if model_options.key?(:changing_values_with)
          _change_value = method(:change_value)

          model.send(:define_method, "#{attribute_name}=") do |value|
            super(_change_value.call(value))
          end
        end
      end

      model_creator.call
    end

    def model_name
      args.fetch(:model_name, DEFAULT_MODEL_NAME)
    end

    def attribute_name
      args.fetch(:attribute_name, DEFAULT_ATTRIBUTE_NAME)
    end

    protected

    attr_reader :args, :model_customizer

    private

    def model_creation_strategy
      args.fetch(:model_creation_strategy)
    end

    def columns
      { column_name => column_options.merge(type: column_type) }
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
      when :never_falsy
        value || 'something different'
      when :never_blank
        value.presence || 'something different'
      when :always_nil
        nil
      when :add_character
        value + 'a'
      when :remove_character
        value.chop
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

    def column_options
      args.fetch(:column_options, {})
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

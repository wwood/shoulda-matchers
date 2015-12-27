module UnitTests
  class ValidationMatcherScenario
    attr_reader :matcher

    def initialize(args)
      @args = args.deep_dup
      @matcher_proc = @args.delete(:matcher_proc)
      @existing_value_specified = @args.key?(:existing_value)
      @existing_value = @args.delete(:existing_value) { nil }

      @specified_model_creator = @args.delete(:model_creator) do
        raise KeyError.new(<<-MESSAGE)
:model_creator is missing. You can either provide it as an option or as
a method.
        MESSAGE
      end

      @model_creator = model_creator_class.new(@args)
    end

    def record
      @_record ||= model.new.tap do |record|
        if existing_value_specified?
          record.public_send("#{attribute_name}=", existing_value)
        end
      end
    end

    def model
      @_model ||= model_creator.call
    end

    def matcher
      @_matcher ||= matcher_proc.call(attribute_name)
    end

    protected

    attr_reader(
      :args,
      :existing_value,
      :matcher_proc,
      :model_creator,
      :specified_model_creator,
    )

    private

    delegate :attribute_name, to: :model_creator

    def existing_value_specified?
      @existing_value_specified
    end

    def model_creator_class
      UnitTests::ModelCreators.retrieve(specified_model_creator) ||
        specified_model_creator
    end
  end
end

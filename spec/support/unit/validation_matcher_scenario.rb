module UnitTests
  class ValidationMatcherScenario
    attr_reader :matcher

    def initialize(args)
      @args = args.dup
      @matcher_proc = args.delete(:matcher_proc)
    end

    def record
      model.new
    end

    def model
      @_model ||= model_creator.call
    end

    def matcher
      @_matcher ||= matcher_proc.call(model_creator.attribute_name)
    end

    protected

    attr_reader :args, :matcher_proc

    def model_creator
      @_model_creator ||= UnitTests::CreateModel.new(args)
    end
  end
end
module UnitTests
  class ValidationMatcherScenario
    attr_reader :matcher

    def initialize(args)
      @args = args.dup
      @matcher_proc = args.delete(:matcher_proc)
    end

    def record
      if args.key?(:build_scenario_object)
        args[:build_scenario_object].call(args)
      else
        model.new
      end
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
      @_model_creator ||= model_creator_class.new(args)
    end

    def model_creator_class
      UnitTests::ModelCreators.retrieve(given_model_creator) ||
        given_model_creator
    end

    def given_model_creator
      args.fetch(:model_creator)
    end
  end
end

module UnitTests
  module ValidationMatcherScenarioHelpers
    def self.configure_example_group(example_group)
      example_group.include(self)
    end

    def build_scenario_for_validation_matcher(args)
      matcher_proc = method(matcher_name)
      scenario_args = args.merge(
        matcher_name: matcher_name,
        matcher_proc: matcher_proc,
      )

      if respond_to?(:model_creation_strategy)
        scenario_args[:model_creation_strategy] = model_creation_strategy
      elsif respond_to?(:build_scenario_object)
        scenario_args[:build_scenario_object] = method(:build_scenario_object)
      else
        scenario_args[:model_creation_strategy] = args.fetch(
          :model_creation_strategy,
          UnitTests::ModelCreationStrategies::ActiveModel
        )
      end

      UnitTests::ValidationMatcherScenario.new(scenario_args)
    end

    def matcher_name
      raise NotImplementedError.new(
        'Please implement #matcher_name in your example group'
      )
    end
  end
end

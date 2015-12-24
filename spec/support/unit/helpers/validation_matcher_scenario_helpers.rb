module UnitTests
  module ValidationMatcherScenarioHelpers
    def self.configure_example_group(example_group)
      example_group.include(self)
    end

    def build_scenario_for_validation_matcher(args)
      matcher_proc = method(matcher_name)
      model_creation_strategy = args.fetch(
        :model_creation_strategy,
        UnitTests::ModelCreationStrategies::ActiveModel
      )

      UnitTests::ValidationMatcherScenario.new(
        args.merge(
          matcher_name: matcher_name,
          matcher_proc: matcher_proc,
          model_creation_strategy: model_creation_strategy
        )
      )
    end

    def matcher_name
      raise NotImplementedError.new(
        "Please implement #matcher_name in your example group"
      )
    end
  end
end

module UnitTests
  module ValidationMatcherScenarioHelpers
    def self.configure_example_group(example_group)
      example_group.include(self)
    end

    def build_scenario_for_validation_matcher(args)
      UnitTests::ValidationMatcherScenario.new(
        build_validation_matcher_scenario_args(args)
      )
    end

    private

    def build_validation_matcher_scenario_args(args)
      args.
        deep_merge(validation_matcher_scenario_args).
        deep_merge(
          matcher_name: matcher_name,
          matcher_proc: method(matcher_name)
        )
    end

    def matcher_name
      validation_matcher_scenario_args.fetch(:matcher_name) do
        raise KeyNotFoundError.new(<<-MESSAGE)
Please implement #validation_matcher_scenario_args in your example
group in such a way that it returns a hash that contains a :matcher_name
key.
        MESSAGE
      end
    end

    def validation_matcher_scenario_args
      raise NotImplementedError.new(<<-MESSAGE)
Please implement #validation_matcher_scenario_args in your example
group. (It should return a hash that contains at least a :matcher_name
key.)
      MESSAGE
    end
  end
end

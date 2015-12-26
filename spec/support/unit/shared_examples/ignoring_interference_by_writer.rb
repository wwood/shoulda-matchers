shared_examples_for 'ignoring_interference_by_writer' do |common_config|
  define_method(:common_config) { common_config }

  context 'when the writer method for the attribute changes incoming values' do
    context 'and the matcher has not been qualified with ignoring_interference_by_writer' do
      config_for_test = common_config[:raise_if_not_qualified]

      if config_for_test
        it 'raises an AttributeChangedValueError' do
          args = build_args(config_for_test)
          scenario = build_scenario_for_validation_matcher(args)
          matcher = matcher_from(scenario)

          assertion = lambda do
            expect(scenario.record).to matcher
          end

          expect(&assertion).to raise_error(
            Shoulda::Matchers::ActiveModel::AllowValueMatcher::AttributeChangedValueError
          )
        end
      end
    end

    context 'and the matcher has been qualified with ignoring_interference_by_writer' do
      context 'and the value change does not cause a test failure' do
        config_for_test = common_config[:accept_if_qualified_but_changing_value_does_not_interfere]

        if config_for_test
          it 'accepts (and does not raise an error)' do
            args = build_args(config_for_test)
            scenario = build_scenario_for_validation_matcher(args)
            matcher = matcher_from(scenario)

            expect(scenario.record).to matcher.ignoring_interference_by_writer
          end
        end
      end

      context 'and the value change causes a test failure' do
        config_for_test = common_config[:reject_if_qualified_but_changing_value_interferes]

        if config_for_test
          it 'lists how the value got changed in the failure message' do
            args = build_args(config_for_test)
            scenario = build_scenario_for_validation_matcher(args)
            matcher = matcher_from(scenario)

            assertion = lambda do
              expect(scenario.record).to matcher.ignoring_interference_by_writer
            end

            if config_for_test.key?(:expected_message_includes)
              message = config_for_test[:expected_message_includes]
              expect(&assertion).to fail_with_message_including(message)
            else
              message = config_for_test[:expected_message]
              expect(&assertion).to fail_with_message(message)
            end
          end
        end
      end
    end
  end

  def build_args(config_for_test)
    args = {
      model_options: {
        changing_values_with: config_for_test.fetch(:changing_values_with)
      }
    }

    args.merge!(common_config.slice(:model_creator, :column_type))
    args.merge!(config_for_test.slice(:model_name, :attribute_name))

    args
  end

  def matcher_from(scenario)
    scenario.matcher.tap do |matcher|
      if respond_to?(:configure_validation_matcher)
        configure_validation_matcher(matcher)
      end
    end
  end
end

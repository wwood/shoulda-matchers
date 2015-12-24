shared_examples_for 'ignoring_interference_by_writer' do |common_config|
  define_method(:common_config) { common_config }

  context 'when the writer method for the attribute changes incoming values' do
    context 'and the matcher has not been qualified with ignoring_interference_by_writer' do
      config_for_test = common_config[:raise_if_not_qualified]

      if config_for_test
        it 'raises an AttributeChangedValueError' do
          args = build_args(config_for_test)
          builder = build_scenario_for_validation_matcher(args)
          matcher = matcher_from(builder)

          assertion = lambda do
            expect(builder.record).to matcher
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
            builder = build_scenario_for_validation_matcher(args)
            matcher = matcher_from(builder)

            expect(builder.record).to matcher.ignoring_interference_by_writer
          end
        end
      end

      context 'and the value change causes a test failure' do
        config_for_test = common_config[:reject_if_qualified_but_changing_value_interferes]

        if config_for_test
          it 'lists how the value got changed in the failure message' do
            args = build_args(config_for_test)
            builder = build_scenario_for_validation_matcher(args)
            matcher = matcher_from(builder)
            message = config_for_test.fetch(:expected_message)

            assertion = lambda do
              expect(builder.record).to matcher.ignoring_interference_by_writer
            end

            expect(&assertion).to fail_with_message(message)
          end
        end
      end
    end
  end

  def model_creator
    common_config.fetch(:model_creator, UnitTests::ActiveRecord::CreateModel)
  end

  def column_type
    common_config.fetch(:column_type, :string)
  end

  def build_args(config_for_test)
    args = {
      model_creator: model_creator,
      column_type: column_type,
      model_options: {
        changing_values_with: config_for_test.fetch(:changing_values_with)
      }
    }

    args.merge!(config_for_test.slice(:model_name, :attribute_name))

    if respond_to?(:validation_options)
      args[:validation_options] = validation_options
    end

    args
  end

  def matcher_from(builder)
    builder.matcher.tap do |matcher|
      if respond_to?(:configure_matcher)
        configure_matcher(matcher)
      end
    end
  end
end

shared_examples_for 'ignoring_interference_by_writer' do |config|
  model_creator = config.fetch(
    :model_creator,
    UnitTests::ActiveRecord::CreateModel
  )
  column_type = config.fetch(:column_type, :string)

  context 'when the writer method for the attribute changes incoming values' do
    context 'and the matcher has not been qualified with ignoring_interference_by_writer' do
      local_config = config[:raise_if_not_qualified]

      if local_config
        it 'raises an AttributeChangedValueError' do
          builder = build_scenario_for_validation_matcher(
            model_creator: model_creator,
            column_type: column_type,
            model_options: {
              changing_values_with: local_config.fetch(:changing_values_with)
            }
          )

          assertion = lambda do
            expect(builder.record).to builder.matcher
          end

          expect(&assertion).to raise_error(
            Shoulda::Matchers::ActiveModel::AllowValueMatcher::AttributeChangedValueError
          )
        end
      end
    end

    context 'and the matcher has been qualified with ignoring_interference_by_writer' do
      context 'and the value change does not cause a test failure' do
        local_config = config[:accept_if_qualified_but_changing_value_does_not_interfere]

        if local_config
          it 'accepts (and does not raise an error)' do
            builder = build_scenario_for_validation_matcher(
              model_creator: model_creator,
              column_type: column_type,
              model_options: {
                changing_values_with: local_config.fetch(:changing_values_with)
              }
            )

            expect(builder.record).
              to builder.matcher.ignoring_interference_by_writer
          end
        end
      end

      context 'and the value change causes a test failure' do
        local_config = config[:reject_if_qualified_but_changing_value_interferes]

        if local_config
          it 'lists how the value got changed in the failure message' do
            builder_args = {
              model_creator: model_creator,
              column_type: column_type,
              model_options: {
                changing_values_with: local_config.fetch(:changing_values_with)
              }
            }

            builder_args.merge!(
              local_config.slice(:model_name, :attribute_name)
            )

            builder = build_scenario_for_validation_matcher(builder_args)

            assertion = lambda do
              expect(builder.record).
                to builder.matcher.ignoring_interference_by_writer
            end

            message = local_config.fetch(:expected_message)

            expect(&assertion).to fail_with_message(message)
          end
        end
      end
    end
  end
end

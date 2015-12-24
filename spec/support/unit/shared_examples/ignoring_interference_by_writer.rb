shared_examples_for 'ignoring_interference_by_writer' do |config|
  model_creator = config.fetch(
    :model_creator,
    UnitTests::ActiveRecord::CreateModel
  )
  column_type = config.fetch(:column_type, :string)

  context 'when the writer method for the attribute changes incoming values' do
    context 'and the matcher has not been qualified with ignoring_interference_by_writer' do
      if config[:raise_if_not_qualified]
        it 'raises an AttributeChangedValueError' do
          builder = build_scenario_for_validation_matcher(
            model_creator: model_creator,
            column_type: column_type,
            model_options: config[:raise_if_not_qualified]
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
        if config[:accept_if_qualified_but_changing_value_interferes]
          it 'accepts (and does not raise an error)' do
            builder = build_scenario_for_validation_matcher(
              model_creator: model_creator,
              column_type: column_type,
              model_options: config[:accept_if_qualified_but_changing_value_interferes]
            )

            expect(builder.record).
              to builder.matcher.ignoring_interference_by_writer
          end
        end
      end
    end
  end
end

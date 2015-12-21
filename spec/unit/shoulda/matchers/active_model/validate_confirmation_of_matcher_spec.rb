require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateConfirmationOfMatcher, type: :model do
  include UnitTests::ConfirmationMatcherHelpers

  context '#description' do
    it 'states that the confirmation must match its base attribute' do
      builder = builder_for_record_validating_confirmation
      message = "validate that :#{builder.confirmation_attribute} matches :#{builder.attribute_to_confirm}"
      matcher = described_class.new(builder.attribute_to_confirm)
      expect(matcher.description).to eq(message)
    end
  end

  context 'when the model has a confirmation validation' do
    it 'passes' do
      builder = builder_for_record_validating_confirmation
      expect(builder.record).
        to validate_confirmation_of(builder.attribute_to_confirm)
    end

    context 'when a nil message is specified' do
      it 'ignores it' do
        builder = builder_for_record_validating_confirmation
        expect(builder.record).
          to validate_confirmation_of(builder.attribute_to_confirm).
          with_message(nil)
      end
    end
  end

  context 'when the model does not have a confirmation attribute' do
    it 'raises an AttributeDoesNotExistError' do
      model = define_model(:example)

      assertion = lambda do
        expect(model.new).to validate_confirmation_of(:attribute_to_confirm)
      end

      message = <<-MESSAGE.rstrip
The matcher attempted to set :attribute_to_confirm_confirmation to "some
value" on the Example, but that attribute does not exist.
      MESSAGE

      expect(&assertion).to raise_error(
        Shoulda::Matchers::ActiveModel::AllowValueMatcher::AttributeDoesNotExistError,
        message
      )
    end
  end

  context 'when the model does not have the attribute under test' do
    it 'raises an AttributeDoesNotExistError' do
      model = define_model(:example, attribute_to_confirm_confirmation: :string)

      assertion = lambda do
        expect(model.new).to validate_confirmation_of(:attribute_to_confirm)
      end

      message = <<-MESSAGE.rstrip
The matcher attempted to set :attribute_to_confirm to "different value"
on the Example, but that attribute does not exist.
      MESSAGE

      expect(&assertion).to raise_error(
        Shoulda::Matchers::ActiveModel::AllowValueMatcher::AttributeDoesNotExistError,
        message
      )
    end
  end

  context 'when the model has all attributes, but does not have the validation' do
    it 'fails with an appropriate failure message' do
      model = define_model(:example, attribute_to_confirm: :string) do
        attr_accessor :attribute_to_confirm_confirmation
      end

      assertion = lambda do
        expect(model.new).to validate_confirmation_of(:attribute_to_confirm)
      end

      message = <<-MESSAGE
Example did not properly validate that
:attribute_to_confirm_confirmation matches :attribute_to_confirm.
  After setting :attribute_to_confirm_confirmation to ‹"some value"›,
  then setting :attribute_to_confirm to ‹"different value"›, the matcher
  expected the Example to be invalid, but it was valid instead.
      MESSAGE

      expect(&assertion).to fail_with_message(message)
    end
  end

  context 'when both validation and matcher specify a custom message' do
    it 'passes when the expected and actual messages match' do
      builder = builder_for_record_validating_confirmation(message: 'custom')
      expect(builder.record).
        to validate_confirmation_of(builder.attribute_to_confirm).
        with_message(/custom/)
    end

    it 'fails when the expected and actual messages do not match' do
      builder = builder_for_record_validating_confirmation(message: 'custom')
      expect(builder.record).
        not_to validate_confirmation_of(builder.attribute_to_confirm).
        with_message(/wrong/)
    end
  end

  context 'when the validation specifies a message via i18n' do
    it 'passes' do
      builder = builder_for_record_validating_confirmation_with_18n_message
      expect(builder.record).
        to validate_confirmation_of(builder.attribute_to_confirm)
    end
  end

  context 'when the writer method for the attribute changes incoming values' do
    context 'and the matcher has not been qualified with ignoring_interference_by_writer' do
      it 'raises an AttributeChangedValueError' do
        builder = builder_for_record_validating_confirmation(
          attribute: :password
        )

        builder.model.class_eval do
          def password=(value)
            super(value.upcase)
          end
        end

        assertion = lambda do
          expect(builder.record).to validate_confirmation_of(:password)
        end

        expect(&assertion).to raise_error(
          Shoulda::Matchers::ActiveModel::AllowValueMatcher::AttributeChangedValueError
        )
      end
    end

    context 'and the matcher has been qualified with ignoring_interference_by_writer' do
      it 'fails, but then lists how values were changed' do
        builder = builder_for_record_validating_confirmation(
          attribute: :password
        )

        builder.model.class_eval do
          def password=(value)
            super(value.upcase)
          end
        end

        assertion = lambda do
          expect(builder.record).
            to validate_confirmation_of(:password).
            ignoring_interference_by_writer
        end

        message = <<-MESSAGE
Example did not properly validate that :password_confirmation matches
:password.
  After setting :password_confirmation to "same value", then setting
  :password to "same value" -- which was read back as "SAME VALUE" --
  the matcher expected the Example to be valid, but it was invalid
  instead, producing these validation errors:

  * password_confirmation: ["doesn't match Password"]

  As indicated in the message above, :password seems to be changing
  certain values as they are set, and this could have something to do
  with why this test is failing. If you've overridden the writer method
  for this attribute, then you may need to change it to make this test
  pass, or do something else entirely.
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end
    end
  end
end

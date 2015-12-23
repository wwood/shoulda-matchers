require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateLengthOfMatcher, type: :model do
  context 'an attribute with a non-zero minimum length validation' do
    it 'accepts ensuring the correct minimum length' do
      expect(validating_length(minimum: 4)).
        to validate_length_of(:attr).is_at_least(4)
    end

    it 'rejects ensuring a lower minimum length with any message' do
      expect(validating_length(minimum: 4)).
        not_to validate_length_of(:attr).is_at_least(3).with_short_message(/.*/)
    end

    it 'rejects ensuring a higher minimum length with any message' do
      expect(validating_length(minimum: 4)).
        not_to validate_length_of(:attr).is_at_least(5).with_short_message(/.*/)
    end

    it 'does not override the default message with a blank' do
      expect(validating_length(minimum: 4)).
        to validate_length_of(:attr).is_at_least(4).with_short_message(nil)
    end

    context 'when the writer method for the attribute changes incoming values' do
      context 'and the matcher has not been qualified with ignoring_interference_by_writer' do
        it 'raises an AttributeChangedValueError' do
          model = define_model_validating_length(
            attribute_name: :name,
            minimum: 4
          )

          model.class_eval do
            def name=(name)
              super(name.upcase)
            end
          end

          assertion = lambda do
            expect(model.new).to validate_length_of(:name).is_at_least(4)
          end

          expect(&assertion).to raise_error(
            Shoulda::Matchers::ActiveModel::AllowValueMatcher::AttributeChangedValueError
          )
        end
      end

      context 'and the matcher has been qualified with ignoring_interference_by_writer' do
        context 'and the value change does not cause a test failure' do
          it 'accepts (and does not raise an error)' do
            model = define_model_validating_length(
              attribute_name: :name,
              minimum: 4
            )

            model.class_eval do
              def name=(name)
                super(name.upcase)
              end
            end

            expect(model.new).
              to validate_length_of(:name).
              is_at_least(4).
              ignoring_interference_by_writer
          end
        end

        context 'and the value change causes a test failure' do
          it 'lists how the value got changed in the failure message' do
            model = define_model_validating_length(
              attribute_name: :name,
              minimum: 4
            )

            model.class_eval do
              def name=(name)
                super(name + 'j')
              end
            end

            assertion = lambda do
              expect(model.new).
                to validate_length_of(:name).
                is_at_least(4).
                ignoring_interference_by_writer
            end

            message = <<-MESSAGE
Example did not properly validate that the length of :name is at least
4.
  After setting :name to ‹"xxx"› -- which was read back as ‹"xxxj"› --
  the matcher expected the Example to be invalid, but it was valid
  instead.

  As indicated in the message above, :name seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE

            expect(&assertion).to fail_with_message(message)
          end
        end
      end
    end
  end

  context 'an attribute with a minimum length validation of 0' do
    it 'accepts ensuring the correct minimum length' do
      expect(validating_length(minimum: 0)).
        to validate_length_of(:attr).is_at_least(0)
    end
  end

  context 'an attribute with a maximum length' do
    it 'accepts ensuring the correct maximum length' do
      expect(validating_length(maximum: 4)).
        to validate_length_of(:attr).is_at_most(4)
    end

    it 'rejects ensuring a lower maximum length with any message' do
      expect(validating_length(maximum: 4)).
        not_to validate_length_of(:attr).is_at_most(3).with_long_message(/.*/)
    end

    it 'rejects ensuring a higher maximum length with any message' do
      expect(validating_length(maximum: 4)).
        not_to validate_length_of(:attr).is_at_most(5).with_long_message(/.*/)
    end

    it 'does not override the default message with a blank' do
      expect(validating_length(maximum: 4)).
        to validate_length_of(:attr).is_at_most(4).with_long_message(nil)
    end

    context 'when the writer method for the attribute changes incoming values' do
      context 'and the matcher has not been qualified with ignoring_interference_by_writer' do
        it 'raises an AttributeChangedValueError' do
          model = define_model_validating_length(
            attribute_name: :name,
            maximum: 4
          )

          model.class_eval do
            def name=(name)
              super(name.upcase)
            end
          end

          assertion = lambda do
            expect(model.new).to validate_length_of(:name).is_at_most(4)
          end

          expect(&assertion).to raise_error(
            Shoulda::Matchers::ActiveModel::AllowValueMatcher::AttributeChangedValueError
          )
        end
      end

      context 'and the matcher has been qualified with ignoring_interference_by_writer' do
        context 'and the value change does not cause a test failure' do
          it 'accepts (and does not raise an error)' do
            model = define_model_validating_length(
              attribute_name: :name,
              maximum: 4
            )

            model.class_eval do
              def name=(name)
                super(name.upcase)
              end
            end

            expect(model.new).
              to validate_length_of(:name).
              is_at_most(4).
              ignoring_interference_by_writer
          end
        end

        context 'and the value change causes a test failure' do
          it 'lists how the value got changed in the failure message' do
            model = define_model_validating_length(
              attribute_name: :name,
              maximum: 4
            )

            model.class_eval do
              def name=(name)
                super(name.chop)
              end
            end

            assertion = lambda do
              expect(model.new).
                to validate_length_of(:name).
                is_at_most(4).
                ignoring_interference_by_writer
            end

            message = <<-MESSAGE
Example did not properly validate that the length of :name is at most 4.
  After setting :name to ‹"xxxxx"› -- which was read back as ‹"xxxx"› --
  the matcher expected the Example to be invalid, but it was valid
  instead.

  As indicated in the message above, :name seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
            MESSAGE

            expect(&assertion).to fail_with_message(message)
          end
        end
      end
    end
  end

  context 'an attribute with a required exact length' do
    it 'accepts ensuring the correct length' do
      expect(validating_length(is: 4)).
        to validate_length_of(:attr).is_equal_to(4)
    end

    it 'rejects ensuring a lower maximum length with any message' do
      expect(validating_length(is: 4)).
        not_to validate_length_of(:attr).is_equal_to(3).with_message(/.*/)
    end

    it 'rejects ensuring a higher maximum length with any message' do
      expect(validating_length(is: 4)).
        not_to validate_length_of(:attr).is_equal_to(5).with_message(/.*/)
    end

    it 'does not override the default message with a blank' do
      expect(validating_length(is: 4)).
        to validate_length_of(:attr).is_equal_to(4).with_message(nil)
    end

    context 'and the matcher has been qualified with ignoring_interference_by_writer' do
      context 'and the value change does not cause a test failure' do
        it 'accepts (and does not raise an error)' do
          model = define_model_validating_length(
            attribute_name: :name,
            is: 4
          )

          model.class_eval do
            def name=(name)
              super(name.upcase)
            end
          end

          expect(model.new).
            to validate_length_of(:name).
            is_equal_to(4).
            ignoring_interference_by_writer
        end
      end

      context 'and the value change causes a test failure' do
        it 'lists how the value got changed in the failure message' do
          model = define_model_validating_length(
            attribute_name: :name,
            is: 4
          )

          model.class_eval do
            def name=(name)
              super(name + 'j')
            end
          end

          assertion = lambda do
            expect(model.new).
              to validate_length_of(:name).
              is_equal_to(4).
              ignoring_interference_by_writer
          end

          message = <<-MESSAGE
Example did not properly validate that the length of :name is 4.
  After setting :name to ‹"xxx"› -- which was read back as ‹"xxxj"› --
  the matcher expected the Example to be invalid, but it was valid
  instead.

  As indicated in the message above, :name seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end
      end
    end
  end

  context 'an attribute with a required exact length and another validation' do
    it 'accepts ensuring the correct length' do
      model = define_model(:example, attr: :string) do
        validates_length_of :attr, is: 4
        validates_numericality_of :attr
      end.new

      expect(model).to validate_length_of(:attr).is_equal_to(4)
    end
  end

  context 'an attribute with a custom minimum length validation' do
    it 'accepts ensuring the correct minimum length' do
      expect(validating_length(minimum: 4, too_short: 'foobar')).
        to validate_length_of(:attr).is_at_least(4).with_short_message(/foo/)
    end
  end

  context 'an attribute with a custom maximum length validation' do
    it 'accepts ensuring the correct minimum length' do
      expect(validating_length(maximum: 4, too_long: 'foobar')).
        to validate_length_of(:attr).is_at_most(4).with_long_message(/foo/)
    end
  end

  context 'an attribute with a custom equal validation' do
    it 'accepts ensuring the correct exact length' do
      expect(validating_length(is: 4, message: 'foobar')).
        to validate_length_of(:attr).is_equal_to(4).with_message(/foo/)
    end
  end

  context 'an attribute without a length validation' do
    it 'rejects ensuring a minimum length' do
      expect(define_model(:example, attr: :string).new).
        not_to validate_length_of(:attr).is_at_least(1)
    end
  end

  context 'using translations' do
    after { I18n.backend.reload! }

    context "a too_long translation containing %{attribute}, %{model}" do
      before do
        stub_translation(
          "activerecord.errors.messages.too_long",
          "The %{attribute} of your %{model} is too long (maximum is %{count} characters)")
      end

      it "does not raise an exception" do
        expect {
          expect(validating_length(maximum: 4)).
            to validate_length_of(:attr).is_at_most(4)
        }.to_not raise_exception
      end
    end

    context "a too_short translation containing %{attribute}, %{model}" do
      before do
        stub_translation(
          "activerecord.errors.messages.too_short",
          "The %{attribute} of your %{model} is too short (minimum is %{count} characters)")
      end

      it "does not raise an exception" do
        expect {
          expect(validating_length(minimum: 4)).to validate_length_of(:attr).is_at_least(4)
        }.to_not raise_exception
      end
    end

    context "a wrong_length translation containing %{attribute}, %{model}" do
      before do
        stub_translation(
          "activerecord.errors.messages.wrong_length",
          "The %{attribute} of your %{model} is the wrong length (should be %{count} characters)")
      end

      it "does not raise an exception" do
        expect {
          expect(validating_length(is: 4)).
            to validate_length_of(:attr).is_equal_to(4)
        }.to_not raise_exception
      end
    end
  end

  def define_model_validating_length(options = {})
    options = options.dup
    attribute_name = options.delete(:attribute_name) { :attr }

    define_model(:example, attribute_name => :string) do |model|
      model.validates_length_of(attribute_name, options)
    end
  end

  def validating_length(options = {})
    define_model_validating_length(options).new
  end

  alias_method :build_record_validating_length, :validating_length
end

require_relative '../model_creators'

module UnitTests
  module ModelCreators
    class ActiveRecord
      def self.call(args)
        new(args).call
      end

      delegate(
        :attribute_name,
        :customize_model,
        :model_name,
        to: :model_creator
      )

      def initialize(args)
        @args = args
        @model_creator = UnitTests::CreateModel.new(model_creator_args)
      end

      def call
        model_creator.call
      end

      protected

      attr_reader :args, :model_creator

      private

      def model_creator_args
        args.merge(
          model_creation_strategy: UnitTests::ModelCreationStrategies::ActiveRecord
        )
      end
    end

    register(:active_record, ActiveRecord)
  end
end

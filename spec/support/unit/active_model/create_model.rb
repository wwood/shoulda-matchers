module UnitTests
  module ActiveModel
    class CreateModel
      def self.call(args)
        new(args).call
      end

      def initialize(args)
        @args = args
      end

      def call
        UnitTests::CreateModel.call(model_creation_args)
      end

      private

      def model_creation_args
        args.merge(
          model_creation_strategy: UnitTests::ModelCreationStrategies::ActiveModel
        )
      end
    end
  end
end

require_relative '../../model_creators'

module UnitTests
  module ModelCreators
    class ActiveRecord
      class HasMany
        def self.call(args)
          new(args).call
        end

        def initialize(args)
          @args = args
        end

        def call
          child_model_creator.call
          parent_model_creator.call
        end

        def attribute_name
          args.fetch(:attribute_name, :children)
        end
        alias_method :association_name, :attribute_name

        protected

        attr_reader :args

        private

        def child_model_creator
          @_child_model_creator ||=
            UnitTests::ModelCreationStrategies::ActiveRecord.new(
              child_model_name
            )
        end

        def parent_model_creator
          @_parent_model_creator ||=
            builder = UnitTests::ModelCreators::ActiveRecord.new(
              parent_model_creator_args
            )
            builder.customize_model { |model| model.has_many(association_name) }
            builder
        end

        def child_model_name
          association_name.to_s.classify
        end

        def parent_model_creator_args
          args.merge(attribute_name: attribute_name)
        end
      end
    end

    register(:"active_record/has_many", ActiveRecord::HasMany)
  end
end

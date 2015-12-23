module UnitTests
  module ActiveRecord
    class CreateModelWithHabtm
      def self.call(args)
        new(args).call
      end

      def initialize(args)
        @args = args
      end

      def call
        parent_child_table_creator.call
        child_model_creator.call
        parent_model_creator.call
      end

      protected

      attr_reader :args

      private

      def parent_child_table_creator
        @_parent_child_table_creator ||=
          UnitTests::ActiveRecord::CreateTable.new(
            parent_child_table_name,
            foreign_key_for_child_model => :integer,
            foreign_key_for_parent_model => :integer,
            :id => false
          )
      end

      def child_model_creator
        @_child_model_creator ||=
          UnitTests::ModelCreationStrategies::ActiveRecord.new(
            child_model_name
          )
      end

      def parent_model_creator
        @_parent_model_creator ||= begin
          builder = UnitTests::CreateModel.new(
            parent_model_creator_args
          )
          builder.customize_model { |model| model.has_many(association_name) }
          builder
        end
      end

      def parent_model_creator_args
        args.merge(
          creation_strategy: UnitTests::ModelCreationStrategies::ActiveRecord,
          attribute_name: attribute_name
        )
      end

      def foreign_key_for_child_model
        child_model_name.foreign_key
      end

      def foreign_key_for_parent_model
        name.foreign_key
      end

      def parent_child_table_name
        "#{child_model_name.pluralize}#{name}".tableize
      end

      def child_model_name
        attribute_name.to_s.classify
      end

      def attribute_name
        args.fetch(:attribute_name, :children)
      end
    end
  end
end

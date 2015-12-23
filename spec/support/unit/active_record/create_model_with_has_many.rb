module UnitTests
  module ActiveRecord
    class CreateModelWithHasMany
      def self.call(name, columns = {}, options = {}, &block)
        new(name, columns, options, &block).call
      end

      def initialize(name, columns = {}, options = {}, &block)
        @name = name
        @columns = columns
        @options = options
        @block = block
      end

      def call
        child_model_creator.call
        parent_model_creator.call
      end

      protected

      attr_reader(
        :block,
        :child_model_creator,
        :columns,
        :name,
        :options,
        :parent_model_creator,
      )

      private

      def child_model_creator
        @_child_model_creator ||= ModelBuilder.new(child_model_name)
      end

      def parent_model_creator
        @_parent_model_creator ||=
          ModelBuilder.new(name, columns, options, &block).tap do |builder|
            builder.customize_model do |model|
              model.has_many(association_name)
            end
          end
      end

      def child_model_name
        association_name.to_s.classify
      end

      def association_name
        options.fetch(:attribute_name, :children)
      end
    end
  end
end

module UnitTests
  module ModelCreationStrategies
    class ActiveModel
      def self.call(name, columns = {}, options = {}, &block)
        new(name, columns, options, &block).call
      end

      def initialize(name, columns = {}, options = {}, &block)
        @name = name
        @columns = columns
        @block = block
      end

      def call
        ClassBuilder.define_class(name).tap do |model|
          model.send(:include, ::ActiveModel::Validations)
          model.send(:include, attributes_module)

          model.send(:define_method, :initialize) do |attributes = {}|
            attributes.each do |name, value|
              public_send("#{name}=", value)
            end
          end

          if block
            if block.arity == 0
              model.class_eval(&block)
            else
              block.call(model)
            end
          end
        end
      end

      protected

      attr_reader :name, :columns, :block

      private

      def attributes_module
        _columns = columns

        @_attributes_module ||= Module.new do
          attr_accessor(*_columns.keys)
        end
      end
    end
  end
end

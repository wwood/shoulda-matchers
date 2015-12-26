module UnitTests
  module ModelCreationStrategies
    class ActiveModel
      def self.call(name, columns = {}, &block)
        new(name, columns, &block).call
      end

      def initialize(name, columns = {}, &block)
        @name = name
        @columns = columns
        @model_customizers = []

        if block
          customize_model(&block)
        end
      end

      def customize_model(&block)
        model_customizers << block
      end

      def call
        ClassBuilder.define_class(name, Model).tap do |model|
          model.columns = columns.keys
          model.send(:include, attributes_module)

          model_customizers.each do |block|
            run_block(model, block)
          end
        end
      end

      protected

      attr_reader :name, :columns, :block, :model_customizers

      private

      def attributes_module
        _columns = columns

        @_attributes_module ||= Module.new do
          attr_accessor(*_columns.keys)
        end
      end

      def run_block(model, block)
        if block
          if block.arity == 0
            model.class_eval(&block)
          else
            block.call(model)
          end
        end
      end

      class Model
        class << self
          attr_reader :columns

          def columns=(columns)
            @columns = columns.map(&:to_sym)
          end
        end

        self.columns = []

        include ::ActiveModel::Model

        attr_reader :attributes

        def initialize(attributes = {})
          @attributes = attributes.symbolize_keys
        end

        def inspect
          middle = '%s:0x%014x%s' % [
            self.class,
            object_id * 2,
            ' ' + inspected_attributes.join(' ')
          ]

          "#<#{middle.strip}>"
        end

        private

        def method_missing(name, *args, &block)
          if name.end_with?('=')
            name = name.chop

            if attributes.key?(name)
              attributes[name] = args.first
            else
              super
            end
          elsif attributes.key?(name)
            attributes[name]
          else
            super
          end
        end

        def respond_to_missing?(name, include_private = true)
          attributes.key?(name) || super
        end

        def inspected_attributes
          self.class.columns.
            map { |key, value| "#{key}: #{attributes[key].inspect}" }
        end
      end
    end
  end
end

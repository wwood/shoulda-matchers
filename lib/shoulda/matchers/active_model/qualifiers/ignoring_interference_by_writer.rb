module Shoulda
  module Matchers
    module ActiveModel
      module Qualifiers
        # @private
        module IgnoringInterferenceByWriter
          def initialize(*args)
            @ignore_interference_by_writer = IgnoreInterferenceByWriter.new
          end

          def ignoring_interference_by_writer(value = :always)
            @ignore_interference_by_writer.set(value)
            self
          end

          def ignore_interference_by_writer
            @ignore_interference_by_writer
          end
        end
      end
    end
  end
end

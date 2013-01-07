module ToSource

  class Command
    include Adamantium::Flat

    NULL = Class.new(self) do
      def run(_state)
      end
    end.new.freeze

    class Token < self
      attr_reader :content

      def run(state)
        state.push(self)
      end

    private

      def initialize(content)
        @content = content
      end
    end

    class Shift < self
      include Equalizer.new(:width)

      attr_reader :width

      def run(state)
        state.shift(width)
      end

    private

      def initialize(width)
        @width = width
      end

      INDENT   = Shift.new( 2)
      UNINDENT = Shift.new(-2)
    end
  end
end

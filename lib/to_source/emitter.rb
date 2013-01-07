module ToSource

  class Emitter
    include Adamantium::Flat, Equalizer.new(:node)

    REGISTRY = {}

    def self.handle(node_class)
      REGISTRY[node_class]=self
    end

    def self.build(node, buffer = [])
      REGISTRY.fetch(node.class).new(node, buffer)
    end

    def self.run(node)
      build(node).source
    end


    def source
      state = State.new
      buffer.each do |command|
        state.execute(command)
      end
      state.source
    end

    attr_reader :node

  private

    def push(command)
      buffer.push(command)
    end

    def new_line
      emit("\n")
    end

    def space
      emit(' ')
    end

    def emit_end
      emit(:end)
    end

    def indent
      push(Command::Shift::INDENT)
    end

    def unindent
      push(Command::Shift::UNINDENT)
    end

    def emit(name)
      push(Command::Token.new(name))
    end

    def visit(node)
      self.class.build(node, buffer)
    end

    def run(emitter, node = self.node)
      emitter.new(node, buffer)
    end

    attr_reader :buffer

    def initialize(node, buffer)
      @node, @buffer = node, buffer
      dispatch
    end
  end
end

module ToSource

  class Buffer
    include Adamantium::Flat

    attr_reader :lines

    def initialize(lines = [])
      @lines = lines
    end

    def to_s
      @lines.join("\n")
    end

    def indent
      new(lines.map { |line| "  #{line}" })
    end

    def body(body)
      self
    end

    def class_open(name, superclass)
      push('class')
    end

    def push(token)
      new(lines.dup << token)
    end

    def end
      push('end')
    end

    def new(*args)
      self.class.new(*args)
    end
  end

end

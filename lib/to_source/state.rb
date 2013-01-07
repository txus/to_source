module ToSource
  class State

    attr_reader :last
    attr_reader :identation
    attr_reader :buffer

    def initialize
      @last        = Command::NULL
      @indentation = 0
      @buffer      = []
    end

    def execute(command)
      command.run(self)
      @last = command
    end

    def last_keyword?
      last.kind_of?(Command::Token::Keyword)
    end

    def write(string)
      @buffer << string
    end

    def space
      write(' ')
    end

    def push(command)
      indent
      write(command.content)
    end

    def indent
      return unless blank?
      write(' ' * @indentation)
    end

    def blank?
      buffer.last == "\n"
    end

    def new_line
      write("\n")
    end

    def source
      buffer.join('')
    end

    def shift(width)
      @indentation += width
      @indentation = 0 if @indentation < 0
      new_line
    end
  end
end

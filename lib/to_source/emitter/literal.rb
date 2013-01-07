module ToSource
  class Emitter

    class Literal < self

      class EmptyArray < self

        handle(Rubinius::AST::EmptyArray)

        def dispatch
          emit('[]')
        end
      end

      class Array < self

        handle(Rubinius::AST::ArrayLiteral)

      private

        def dispatch
          emit('[')
          run(Util::DelimitedBody, node.body)
          emit(']')
        end
      end

      class Range < self

      private

        def dispatch
          visit(node.start)
          emit(token)
          visit(node.finish)
        end

        def token
          self.class::TOKEN
        end

        class Inclusive < self
          handle(Rubinius::AST::Range)
          TOKEN = '..'
        end

        class Exclude < self
          handle(Rubinius::AST::RangeExclude)
          TOKEN = '...'
        end

      end

      class Hash < self

        handle(Rubinius::AST::HashLiteral)

        def dispatch
          body = node.array.each_slice(2).to_a

          max = body.length - 1

          emit '{'

          body.each_with_index do |slice, index|
            key, value = slice

            visit(key)
            emit ' => '
            visit(value)

            if index < max 
              emit ', ' 
            end
          end

          emit '}'
        end

      end

      class Inspect < self

        handle(Rubinius::AST::SymbolLiteral)

        def dispatch
          emit(value.inspect)
        end

        def value
          node.value
        end

        class Static < self
          def value
            self.class::VALUE
          end

          class True < self
            handle(Rubinius::AST::TrueLiteral)
            VALUE = true
          end

          class False < self
            handle(Rubinius::AST::FalseLiteral)
            VALUE = false
          end

          class Nil < self
            handle(Rubinius::AST::NilLiteral)
            VALUE = nil
          end
        end

        class Regexp < self

          handle(Rubinius::AST::RegexLiteral)

          def value
            ::Regexp.new(node.source)
          end
        end

        class String < self

          handle(Rubinius::AST::StringLiteral)

          def value
            node.string
          end
        end
      end

      class Dynamic < self

        def dispatch
          emit(node.string.inspect[0..-2])
          array.each_with_index do |member, index|
            emit_member(member, index)
          end
        end

        def array
          node.array
        end

        def max
          array.length - 1
        end
        memoize :max

        def emit_primitive_member(member, index)
          last = index < max ? -2 : -1
          range = 1..last
          emit(member.string.inspect[range])
        end

        def emit_member(member, index)
          case member
          when Rubinius::AST::StringLiteral
            emit_primitive_member(member, index)
          else
            visit(member)
          end
        end

        class Symbol < self

          handle(Rubinius::AST::DynamicSymbol)

          def dispatch
            emit(':')
            super
          end

        end

        class String < self

          handle(Rubinius::AST::DynamicString)

        end

        class Execute < self

          handle(Rubinius::AST::DynamicExecuteString)

          def dispatch
            emit('`')
            emit(node.string.inspect[1..-2])
            array.each_with_index do |member, index|
              emit_member(member, index)
            end
            emit('`')
          end

          def emit_primitive_member(member, index)
            last = index < max ? -3 : -2
            range = 1..last
            emit(member.string.inspect[range])
          end

        end

        class Regex < self

          handle(Rubinius::AST::DynamicRegex)

          def dispatch
            emit('/')
            emit(Regexp.new(node.string).inspect[1..-2])
            array.each_with_index do |member, index|
              emit_member(member, index)
            end
            emit('/')
          end

          def emit_primitive_member(member, index)
            last = index < max ? -3 : -2
            range = 1..last
            emit(Regexp.new(member.string).inspect[range])
          end

        end
      end


      class PassThrough < self

        handle(Rubinius::AST::FixnumLiteral)
        handle(Rubinius::AST::FloatLiteral)

        def dispatch
          emit(node.value)
        end

      end
    end
  end
end

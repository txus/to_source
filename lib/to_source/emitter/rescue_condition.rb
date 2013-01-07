module ToSource
  class Emitter

    class RescueCondition < self

      handle(Rubinius::AST::RescueCondition)

    private

      def dispatch
        emit('rescue')
        emit_condition
        emit_splat
        emit_assignment
        emit_body
        emit_next
      end

      def emit_body
        indent
        visit(node.body)
        unindent
      end

      def emit_condition
        conditions = node.conditions || return

        body = conditions.body

        first = body.first
        unless body.one? and first.kind_of?(Rubinius::AST::ConstantAccess) and first.name == :StandardError
          emit(' ')
          run(Util::DelimitedBody, body)
        end
      end

      def emit_splat
        splat = node.splat || return
        emit(',') if node.conditions
        emit(' ')
        visit(node.splat)
      end

      def emit_assignment
        assignment = node.assignment || return
        emit(' => ')
        emit(assignment.name)
      end

      def emit_next
        condition = node.next || return
        visit(node.next)
      end

    end

  end
end

require 'minitest/autorun'
require 'to_source'

module ToSource
  class VisitorTest < MiniTest::Unit::TestCase
    def visit(code)
      visitor = Visitor.new
      ast     = code.to_ast
      ast.visit(visitor)
      visitor.output
    end

    def assert_source(code)
      assert_equal code, visit(code)
    end

    def test_foo
      assert_source "foo = 1\n"
    end
  end
end

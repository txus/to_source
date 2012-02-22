require 'minitest/autorun'
require 'to_source'

module ToSource
  class VisitorTest < MiniTest::Unit::TestCase
    def visit(code)
      visitor = Visitor.new
      ast     = code.to_ast
      ast.lazy_visit(visitor)
      visitor.output
    end

    def assert_source(code)
      assert_equal code, visit(code)
    end

    def test_local_assignment
      assert_source "foo = 1"
    end

    def test_fixnum_literal
      assert_source "1"
    end

    def test_float_literal
      assert_source "1.0"
    end

    def test_string_literal
      assert_source '"foo"'
    end

    def test_symbol_literal
      assert_source ':foo'
    end

    def test_array_literal
      assert_source '[1, 2, 3]'
    end

    def test_hash_literal
      assert_source '{:answer => 42, :bar => :baz}'
    end

    def test_range
      assert_source '20..34'
    end

    def test_regex
      assert_source '/.*/'
    end
  end
end

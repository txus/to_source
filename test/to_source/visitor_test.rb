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

    def assert_converts(expected, code)
      assert_equal expected, visit(code)
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

    def test_true_literal
      assert_source 'true'
    end

    def test_false_literal
      assert_source 'false'
    end

    def test_nil_literal
      assert_source 'nil'
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

    def test_send
      assert_source 'foo.bar'
    end

    def test_send_with_arguments
      assert_converts 'foo.bar(:baz, :yeah)', 'foo.bar :baz, :yeah'
    end

    def test_send_with_arguments_and_empty_block
      assert_converts "foo.bar(:baz, :yeah) do\n  nil\nend", "foo.bar(:baz, :yeah) do\nend"
    end

    def test_send_with_arguments_and_block_with_one_argument
      assert_source "foo.bar(:baz, :yeah) do |a|\n  3\n  4\nend"
    end

    def test_send_with_arguments_and_block_with_arguments
      assert_source "foo.bar(:baz, :yeah) do |a, b|\n  3\n  4\nend"
    end

    def test_lambda
      assert_source "lambda do |a, b|\n  a\nend"
    end
  end
end

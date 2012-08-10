require 'test/unit'
require 'to_source'

module ToSource
  class VisitorTest < Test::Unit::TestCase
    def visit(code)
      code.to_ast.to_source
    end

    def assert_source(code)
      assert_equal code, visit(code)
    end

    def assert_converts(expected, code)
      assert_equal expected, visit(code)
    end

    def test_class
      assert_source "class TestClass\nend"
    end

    def test_class_with_superclass
      assert_source "class TestClass < Object\nend"
    end

    def test_class_with_body
      assert_source "class TestClass\n  1\nend"
    end

    def test_module
      assert_source "module TestModule\nend"
    end

    def test_module_with_body
      assert_source "module TestModule\n  1\nend"
    end

    def test_local_assignment
      assert_source "foo = 1"
    end

    def test_ivar_assignment
      assert_source "@foo = 1"
    end

    def test_local_access
      assert_source "foo = 1\nfoo"
    end

    def test_ivar_access
      assert_source "@foo"
    end

    def test_toplevel_constant_access
      assert_source "::Rubinius"
    end

    def test_constant_access
      assert_source "Rubinius"
    end

    def test_scoped_constant_access
      assert_source "Rubinius::Debugger"
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

    def test_range_exclude
      assert_source '20...34'
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

    def test_proc
      assert_source "Proc.new do\n  a\nend"
    end

    def test_binary_operators
      %w(+ - * / & | && || <<).each do |operator|
        assert_source "1 #{operator} 2"
      end
    end

    def test_expands_binary_equal
      assert_converts "a = a + 2", "a += 2"
      assert_converts "a = a - 2", "a -= 2"
      assert_converts "a = a * 2", "a *= 2"
      assert_converts "a = a / 2", "a /= 2"
      assert_converts "a && a = 2", "a &&= 2"
      assert_converts "a || a = 2", "a ||= 2"
    end

    def test_unary_operators
      assert_source "!1"
      assert_source "!!1"
    end

    def test_if
      assert_source "if 3\n  9\nend"
    end

    def test_if_with_multiple_blocks
      assert_source "if 3\n  9\n  8\nend"
    end

    def test_else
      assert_source "if 3\n  9\nelse\n  9\nend"
    end

    def test_else_with_multiple_blocks
      assert_source "if 3\n  9\n  8\nelse\n  9\n  8\nend"
    end

    def test_unless
      assert_source "unless 3\n  9\nend"
    end

    def test_while
      assert_source "while false\n  3\nend"
    end

    def test_while_with_multiple_blocks
      assert_source "while false\n  3\n  5\nend"
    end

    def test_until
      assert_source "until false\n  3\nend"
    end

    def test_until_with_multiple_blocks
      assert_source "while false\n  3\n  5\nend"
    end

    def test_return
      assert_source "return 9"
    end

    def test_explicitly_send_to_self
      assert_source "self.foo"
    end

    def test_implicitly_send_to_self
      assert_source "foo"
    end

    def test_define
      assert_source "def foo\n  bar\nend"
    end

    def test_define_with_body
      assert_source "def foo\n  bar\nend"
    end

    def test_define_with_argument
      assert_source "def foo(bar)\n  bar\nend"
    end

    def test_define_with_arguments
      assert_source "def foo(bar, baz)\n  bar\nend"
    end

    def test_define_with_optional_argument
      assert_source "def foo(bar = true)\n  bar\nend"
    end

    def test_define_with_formal_and_optional_argument
      assert_source "def foo(bar, baz = true)\n  bar\nend"
    end

    def test_define_with_splat_argument
      assert_source "def foo(*bar)\n  bar\nend"
    end

    def test_define_with_formal_and_splat_argument
      assert_source "def foo(bar, *baz)\n  bar\nend"
    end

    def test_define_with_formal_default_and_splat_argument
      assert_source "def foo(bar, baz = true, *bor)\n  bar\nend"
    end

    def test_define_with_block_argument
      assert_source "def foor(&block)\n  bar\nend"
    end

    def test_define_with_formal_and_block_argument
      assert_source "def foor(bar, &block)\n  bar\nend"
    end
  end
end

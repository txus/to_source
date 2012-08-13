require 'test/unit'
require 'to_source'

module ToSource
  class VisitorTest < Test::Unit::TestCase
    def compress(code)
      lines = code.split("\n")
      match = /\A( *)/.match(lines.first)
      whitespaces = match[1].to_s.length
      stripped = lines.map do |line|
        line[whitespaces..-1]
      end
      joined = stripped.join("\n")
    end

    def visit(code)
      code.to_ast.to_source
    end

    def assert_source(code)
      assert_equal compress(code), visit(code)
    end

    def assert_converts(expected, code)
      assert_equal compress(expected), visit(code)
    end

    def test_class
      assert_source <<-RUBY
        class TestClass
        end
      RUBY
    end

    def test_scoped_class 
      assert_source <<-RUBY
        class SomeNameSpace::TestClass
        end
      RUBY
    end

    def test_deeply_scoped_class 
      assert_source <<-RUBY
        class Some::Name::Space::TestClass
        end
      RUBY
    end

    def test_class_with_superclass
      assert_source <<-RUBY
        class TestClass < Object
        end
      RUBY
    end

    def test_class_with_scoped_superclass
      assert_source <<-RUBY
        class TestClass < SomeNameSpace::Object
        end
      RUBY
    end

    def test_class_with_body
      assert_source <<-RUBY
        class TestClass
          1
        end
      RUBY
    end

    def test_module
      assert_source <<-RUBY 
        module TestModule
        end
      RUBY
    end

    def test_scoped_module 
      assert_source <<-RUBY
        module SomeNameSpace::TestModule
        end
      RUBY
    end

    def test_deeply_scoped_module 
      assert_source <<-RUBY
        module Some::Name::Space::TestModule
        end
      RUBY
    end

    def test_module_with_body
      assert_source <<-RUBY 
        module TestModule
          1
        end
      RUBY
    end

    def test_local_assignment
      assert_source "foo = 1"
    end

    def test_ivar_assignment
      assert_source "@foo = 1"
    end

    def test_local_access
      assert_source <<-RUBY
        foo = 1
        foo
      RUBY
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
      assert_converts <<-RUBY, <<-CONVERTED
        foo.bar(:baz, :yeah) do
          nil
        end
      RUBY
        foo.bar(:baz, :yeah) do
        end
      CONVERTED
    end

    def test_send_with_arguments_and_block_with_one_argument
      assert_source <<-RUBY 
        foo.bar(:baz, :yeah) do |a|
          3
          4
        end
      RUBY
    end

    def test_send_with_arguments_and_block_with_arguments
      assert_source <<-RUBY
        foo.bar(:baz, :yeah) do |a, b|
          3
          4
        end
      RUBY
    end

    def test_lambda
      assert_source <<-RUBY
        lambda do |a, b|
          a
        end
      RUBY
    end

    def test_proc
      assert_source <<-RUBY
        Proc.new do
          a
        end
      RUBY
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
      assert_source <<-RUBY
        if 3
          9
        end
      RUBY
    end

    def test_if_with_multiple_blocks
      assert_source <<-RUBY
        if 3
          9
          8
        end
      RUBY
    end

    def test_else
      assert_source <<-RUBY
        if 3
          9
        else
          9
        end
      RUBY
    end

    def test_else_with_multiple_blocks
      assert_source <<-RUBY
        if 3
          9
          8
        else
          7
          10
        end
      RUBY
    end

    def test_unless
      assert_source <<-RUBY
        unless 3
          9
        end
      RUBY
    end

    def test_while
      assert_source <<-RUBY
        while false
          3
        end
      RUBY
    end

    def test_while_with_multiple_blocks
      assert_source <<-RUBY
        while false
          3
          5
        end
      RUBY
    end

    def test_until
      assert_source <<-RUBY
        until false
          3
        end
      RUBY
    end

    def test_until_with_multiple_blocks
      assert_source <<-RUBY 
        while false
          3
          5
        end
      RUBY
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
      assert_source <<-RUBY
        def foo
          bar
        end
      RUBY
    end

    def test_define_with_body
      assert_source <<-RUBY
        def foo
          bar
        end
      RUBY
    end

    def test_define_with_argument
      assert_source <<-RUBY
        def foo(bar)
          bar
        end
      RUBY
    end

    def test_define_with_arguments
      assert_source <<-RUBY
        def foo(bar, baz)
          bar
        end
      RUBY
    end

    def test_define_with_optional_argument
      assert_source <<-RUBY
        def foo(bar = true)
          bar
        end
      RUBY
    end

    def test_define_with_formal_and_optional_argument
      assert_source <<-RUBY
        def foo(bar, baz = true)
          bar
        end
      RUBY
    end

    def test_define_with_splat_argument
      assert_source <<-RUBY
        def foo(*bar)
          bar
        end
      RUBY
    end

    def test_define_with_formal_and_splat_argument
      assert_source <<-RUBY
        def foo(bar, *baz)
          bar
        end
      RUBY
    end

    def test_define_with_formal_default_and_splat_argument
      assert_source <<-RUBY
        def foo(bar, baz = true, *bor)
          bar
        end
      RUBY
    end

    def test_define_with_block_argument
      assert_source <<-RUBY
        def foor(&block)
          bar
        end
      RUBY
    end

    def test_define_with_formal_and_block_argument
      assert_source <<-RUBY
        def foor(bar, &block)
          bar
        end
      RUBY
    end

    def test_define_signleton_on_self
      assert_source <<-RUBY
        def self.foo
          bar
        end
      RUBY
    end

    def test_define_signleton_on_constant
      assert_source <<-RUBY
        def Foo.bar
          bar
        end
      RUBY
    end

    def test_define_indentation
      assert_source <<-RUBY
        class Foo
          def bar
            nil
          end
        end
      RUBY
    end

    def test_class_identation
      assert_source <<-RUBY
        module Foo
          class X
            def bar
              x = 1
              z.each do |y|
                foo
                @bar = z
              end
            end
          end
        end
      RUBY
    end
  end
end

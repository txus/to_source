require 'spec_helper'

describe ToSource::Visitor,'.run' do
  subject { described_class.run(node) }

  def compress(code)
    lines = code.split("\n")
    match = /\A( *)/.match(lines.first)
    whitespaces = match[1].to_s.length
    stripped = lines.map do |line|
      line[whitespaces..-1]
    end
    joined = stripped.join("\n")
  end

  shared_examples_for 'a source generation method' do
    it 'should create original source' do
      should eql(compress(expected_source))
    end
  end

  def self.assert_source(source)
    let(:node)            { source.to_ast }
    let(:source)          { source        }
    let(:expected_source) { source        }

    it_should_behave_like 'a source generation method'
  end

  def self.assert_converts(converted, source)
    let(:node)            { source.to_ast }
    let(:source)          { source        }
    let(:expected_source) { converted     }
    it_should_behave_like 'a source generation method'
  end

  context 'class nodes' do
    context 'simple' do
      assert_source <<-RUBY
        class TestClass
        end
      RUBY
    end

    context 'scoped' do
      assert_source <<-RUBY
        class SomeNameSpace::TestClass
        end
      RUBY
    end

    context 'deeply scoped' do
      assert_source <<-RUBY
        class Some::Name::Space::TestClass
        end
      RUBY
    end

    context 'with subclass' do
      assert_source <<-RUBY
        class TestClass < Object
        end
      RUBY
    end

    context 'with scoped superclass' do
      assert_source <<-RUBY
        class TestClass < SomeNameSpace::Object
        end
      RUBY
    end

    context 'with body' do
      assert_source <<-RUBY
        class TestClass
          def foo
            :bar
          end
        end
      RUBY
    end
  end

  context 'module nodes' do
    context 'simple' do
      assert_source <<-RUBY 
        module TestModule
        end
      RUBY
    end

    context 'scoped' do
      assert_source <<-RUBY
        module SomeNameSpace::TestModule
        end
      RUBY
    end

    context 'deeply scoped' do
      assert_source <<-RUBY
        module Some::Name::Space::TestModule
        end
      RUBY
    end

    context 'with body' do
      assert_source <<-RUBY
        module TestModule
          def foo
            :bar
          end
        end
      RUBY
    end
  end

  context 'single assignment' do
    context 'to local variable' do
      assert_source 'foo = 1'
    end

    context 'to instance variable' do
      assert_source '@foo = 1'
    end

    context 'to constant' do
      assert_source 'SOME_CONSTANT = 1'
    end
  end

  context 'element assignment' do
    assert_source 'array[index] = value'
  end

  context 'multiple assignment' do
    context 'to local variable' do
      assert_source 'a, b = 1, 2'
    end

    context 'to instance variable' do
      assert_source '@a, @b = 1, 2'
    end

    context 'unbalanced' do
      assert_source 'a, b = foo'
    end
  end

  context 'access' do
    context 'on local variable' do
      assert_source <<-RUBY
        foo = 1
        foo
      RUBY
    end

    context 'on instance variable' do
      assert_source '@foo'
    end

    context 'toplevel constant' do
      assert_source '::Rubinius'
    end

    context 'constant' do
      assert_source 'Rubinius'
    end

    context 'scoped constant' do
      assert_source 'Rubinius::Debugger'
    end
  end

  context 'literal' do
    context 'fixnum' do
      assert_source '1' 
    end

    context 'float' do
      assert_source '1.0'
    end

    context 'negated numeric' do
      assert_source '-1'
    end

    context 'string' do
      assert_source '"foo"'
    end

    context 'symbol' do
      assert_source ':foo'
    end

    context 'true' do
      assert_source 'true'
    end

    context 'false' do
      assert_source 'false'
    end

    context 'nil' do
      assert_source 'nil'
    end

    context 'array' do
      assert_source '[1, 2, 3]'
    end

    context 'hash' do
      assert_source '{:answer => 42, :bar => :baz}'
    end

    context 'inclusive range' do
      assert_source '20..34'
    end

    context 'exclusive range' do
      assert_source '20...34'
    end

    context 'regexp' do
      assert_source '/.*/'
    end

    context 'dynamic string' do
      context 'simple' do
        assert_source '"foo#{bar}baz"'
      end

      context 'with escapes' do
        assert_source '"fo\no#{bar}b\naz"'
      end
    end

    context 'dynamic regexp' do
      context 'simple' do
        assert_source '/foo#{bar}baz/'
      end

      context 'with escapes' do
        assert_source '/fo\no#{bar}b\naz/'
      end
    end
  end

  context 'send' do
    context 'without arguments' do
      assert_source 'foo.bar'
    end

    context 'with arguments' do
      assert_source 'foo.bar(:baz, :yeah)'
    end

    context 'with block' do
      assert_source <<-RUBY
        foo.bar do
          3
          4
        end
      RUBY
    end

    context 'to self' do
      context 'explicitly' do
        assert_source 'self.foo'
      end

      context 'implicitly' do
        assert_source 'foo'
      end
    end

    context 'with block that takes arguments' do
      assert_source <<-RUBY 
        foo.bar do |a|
          3
          4
        end
      RUBY
    end

    context 'with passing block argument' do
      assert_source 'foo.bar(&baz)'
    end

    context 'with formal and  block argument' do
      assert_source 'foo.bar(:baz, &baz)'
    end

    context 'attribute assignment' do
      context 'on foreign object' do
        assert_source 'foo.bar= :baz'
      end

      context 'on self' do
        assert_source 'self.foo= :bar'
      end
    end
  end

  context 'lambda' do
    assert_source <<-RUBY
      lambda do |a, b|
        a
      end
    RUBY
  end

  context 'yield' do
    context 'without arguments' do
      assert_source 'yield'
    end

    context 'with argument' do
      assert_source 'yield a'
    end

    context 'with arguments' do
      assert_source 'yield a, b'
    end
  end

  context 'binary operators' do
    %w(+ - * / & | && || <<).each do |operator|
      context "operator: #{operator}" do
        assert_source "1 #{operator} 2"
      end
    end
  end

  context 'expansion of shortcuts' do
    context 'on += operator' do
      assert_converts 'a = a + 2', 'a += 2'
    end

    context 'on -= operator' do
      assert_converts 'a = a - 2', 'a -= 2'
    end

    context 'on *= operator' do
      assert_converts 'a = a * 2', 'a *= 2'
    end

    context 'on /= operator' do
      assert_converts 'a = a / 2', 'a /= 2'
    end

    context 'on &&= operator' do
      assert_converts 'a && a = 2', 'a &&= 2'
    end

    context 'on ||= operator' do
      assert_converts 'a || a = 2', 'a ||= 2'
    end
  end

  context 'unary operators' do
    context 'negation' do
      assert_source '!1'
    end

    context 'double negation' do
      assert_source '!!1'
    end
  end

  context 'if statement' do
    context 'without else branch' do
      context 'single statement in branch' do
        assert_source <<-RUBY
          if 3
            9
          end
        RUBY
      end

      context 'multiple statements in branch' do
        assert_source <<-RUBY
          if 3
            9
            10
          end
        RUBY
      end
    end

    context 'with else branch' do
      context 'single expression in branch' do
        assert_source <<-RUBY
          if 4
            5
          else
            6
          end
        RUBY
      end

      context 'multiple expressions in branch' do
        assert_source <<-RUBY
          if 4
            5
          else
            6
            7
          end
        RUBY
      end
    end

    context 'unless' do
      context 'single statement in branch' do
        assert_source <<-RUBY
          unless 3
            9
          end
        RUBY
      end

      context 'single statement in branch' do
        assert_source <<-RUBY
          unless 3
            9
            10
          end
        RUBY
      end
    end
  end


  context 'while' do
    context 'single statement in body' do
      assert_source <<-RUBY
        while false
          3
        end
      RUBY
    end

    context 'multiple expressions in body' do
      assert_source <<-RUBY
        while false
          3
          5
        end
      RUBY
    end
  end

  context 'until' do
    context 'with single expression in body' do
      assert_source <<-RUBY
        until false
          3
        end
      RUBY
    end

    context 'with multiple expressions in body' do
      assert_source <<-RUBY 
        while false
          3
          5
        end
      RUBY
    end
  end

  context 'return' do
    context 'with expression' do
      assert_source 'return 9'
    end

    context 'without expression' do
      assert_source 'return'
    end
  end

  context 'define' do
    context 'on instance' do
      context 'without arguments' do
        assert_source <<-RUBY
          def foo
            bar
          end
        RUBY
      end

      context 'with single argument' do
        assert_source <<-RUBY
          def foo(bar)
            bar
          end
        RUBY
      end

      context 'with multiple arguments' do
        assert_source <<-RUBY
          def foo(bar, baz)
            bar
          end
        RUBY
      end

      context 'with optional argument' do
        assert_source <<-RUBY
          def foo(bar = true)
            bar
          end
        RUBY
      end

      context 'with required and optional arguments' do
        assert_source <<-RUBY
          def foo(bar, baz = true)
            bar
          end
        RUBY
      end

      context 'with splat argument' do
        assert_source <<-RUBY
          def foo(*bar)
            bar
          end
        RUBY
      end

      context 'with required and splat arguments' do
        assert_source <<-RUBY
          def foo(bar, *baz)
            bar
          end
        RUBY
      end

      context 'with required optional and splat argument' do
        assert_source <<-RUBY
          def foo(bar, baz = true, *bor)
            bar
          end
        RUBY
      end

      context 'with block argument' do
        assert_source <<-RUBY
          def foor(&block)
            bar
          end
        RUBY
      end

      context 'with required and block arguments' do
        assert_source <<-RUBY
          def foor(bar, &block)
            bar
          end
        RUBY
      end
    end

    context 'on singleton' do
      context 'on self' do
        assert_source <<-RUBY
          def self.foo
            bar
          end
        RUBY
      end

      context 'on constant' do
        assert_source <<-RUBY
          def Foo.bar
            bar
          end
        RUBY
      end
    end
  end
end

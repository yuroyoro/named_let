# -------------------------------------------------------------------------------------------------
#
#  named_let can be used to make the rspec's output easier to read.
#
#  `named_let(:name){ obj }` changes the value which returns 'obj#to_s' and
#  'obj#inspect' to givne :name,
#  then output of 'rspec -format d' will be improved more readable.
#
# -------------------------------------------------------------------------------------------------
#
# rspecのlet(:name)で定義したオブジェクトのto_sとinspectの値を、:nameに変更する
#
# named_let(:foo){ Object.new } ってやると、
# foo.to_sが"foo"になる
#
# named_let(:foo,"label for display"){ ... } って第二引数に別名を渡すと、
# その別名が、to_s/inspectの値になる
#
# subject should == fooとか書いたときの出力が
# ふつうは
#   should == #<Object:0x2aaaaf8a0870>
# とかで汚いけど、これをつかうと
#   should == "label for display"
# のようにキレイになる
#
# -------------------------------------------------------------------------------------------------

require "rspec/core"
require "named_let/version"

module NamedLet
  # In RSpec 2.8,  RSpec::Core::Let::ExampleGroupMethods
  if (RSpec::Core::Version::STRING.split('.').map(&:to_i) <=> [2,8,0]) < 0
    klass = RSpec::Core::Let::ClassMethods
  elsif (RSpec::Core::Version::STRING.split('.').map(&:to_i) <=> [2,13,0]) < 0
    klass = RSpec::Core::Let::ExampleGroupMethods
  else
    klass = RSpec::Core::MemoizedHelpers::ClassMethods
  end

  def extend_for_reporting(obj, the_name)
    return obj if obj.nil?

    # if given -d/--debug option, append calling original ones.(ruby-debug required)
    call_super = begin ;$DEBUG or Debugger.started? rescue LoadError; nil; end

    inject_code = lambda{|o, code| begin; o.instance_eval code; rescue TypeError; end  }
    escape      = lambda{|str| str.gsub(/\"/, '\\"')}

    genereate_wrapper_code = lambda{|o, method|
      original_result = escape.call(o.send(method)) if call_super
      "def #{method}; \"#{the_name}\" #{call_super ? " + \" (#{original_result})\"" : ''} ;end"
    }

    to_s_code    = genereate_wrapper_code.call(obj, :to_s)
    inspect_code = genereate_wrapper_code.call(obj, :inspect)

    inject_code.call(obj, to_s_code)
    inject_code.call(obj, inspect_code)
    obj
  end
  module_function :extend_for_reporting

  klass.class_eval do
    if RSpec::Core::Version::STRING < "3.0"

      # for Rspec2
      def named_let(name, label = nil, &block)

        the_name = label || name

        define_method(name) do
          __memoized.fetch(name) {|k|
            __memoized[k] = instance_eval(&block).tap{|o| NamedLet.extend_for_reporting(o, the_name) }
          }
        end
      end
    else
      # for Rspec3
      def named_let(name, label = nil, &block)
        # We have to pass the block directly to `define_method` to
        # allow it to use method constructs like `super` and `return`.
        raise "#let or #subject called without a block" if block.nil?
        RSpec::Core::MemoizedHelpers.module_for(self).__send__(:define_method, name, &block)

        the_name = label || name

        # Apply the memoization. The method has been defined in an ancestor
        # module so we can use `super` here to get the value.
        if block.arity == 1
          define_method(name) {
            __memoized.fetch_or_store(name) {
              super(RSpec.current_example, &nil).tap{|o| NamedLet.extend_for_reporting(o, the_name) }
            }
          }
        else
          define_method(name) {
            __memoized.fetch_or_store(name) { super(&nil).tap{|o| NamedLet.extend_for_reporting(o, the_name) }}
          }
        end
      end

    end

    def named_let!(name, label = nil, &block)
      named_let(name, label, &block)
      before { __send__(name) }
    end
  end
end

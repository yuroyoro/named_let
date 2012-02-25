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
  if RSpec::Core::Version::STRING < "2.8.0"
    klass = RSpec::Core::Let::ClassMethods
  else
    klass = RSpec::Core::Let::ExampleGroupMethods
  end

  klass.class_eval do
    def named_let(name, label = nil, &block)
      define_method(name) do
        __memoized.fetch(name) {|k| __memoized[k] = instance_eval(&block).tap{|o|
          return o if o.nil?

          the_name = label || name

          # if given -d/--debug option, append calling original ones.(ruby-debug required)
          call_super = begin ;$DEBUG or Debugger.started? rescue LoadError; nil; end

          inject_code = lambda{|obj, code| begin; obj.instance_eval code; rescue TypeError; end  }
          escape      = lambda{|str| str.gsub(/\"/, '\\"')}

          genereate_wrapper_code = lambda{|obj, method|
            original_result = escape.call(obj.send(method)) if call_super
            code = "def #{method}; \"#{the_name}\" #{call_super ? " + \" (#{original_result})\"" : ''} ;end"
          }

          to_s_code    = genereate_wrapper_code.call(o, :to_s)
          inspect_code = genereate_wrapper_code.call(o, :inspect)

          inject_code.call(o, to_s_code)
          inject_code.call(o, inspect_code)
          o
        }}
      end
    end

    def named_let!(name, label = nil, &block)
      named_let(name, label, &block)
      before { __send__(name) }
    end
  end
end

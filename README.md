named_let
==================================

The `named_let` can be used to make the rspec's output easier to read.
It's wrapper function of `let`.

`named_let(:name){ obj }` changes the value which returns 'obj#to_s' and
'obj#inspect' to :name, then output message of 'rspec -format d' be improved more readable.

# Usage

add `require 'named_let'` to your spec_helper.rb or * _spec.rb.


    describe 'named_let' do
      context 'symbol only' do
        named_let(:foo) { Object.new }
        it { foo.to_s should == "foo" }
        it { foo.inspect.should == "foo" }
      end

      context 'with label strings' do
        named_let(:foo,"label for display"){ Object.new }
        it { foo.to_s should == "label for display" }
        it { foo.inspect.should == "label for display" }
       end
    end

You can use `name_let!` to force the method's invocation before each example, like original `let!`.

# Why named_let?

RSpec uses 'Object#inspect' for generating output message from value of specified by `let`.
This will generates unexpected output like 'should == #<Object:0x2aaaaf8a0870A>', it's not human readable.

Now let's use `named_let` instead of `let`.The generaed output will be more readable like 'should == "label for display'.

# Example

For Example, now writing specs for CanCan like bellow,

    require 'spec_helper'
    require "cancan/matchers"

    describe Ability do
      context 'an user' do
        let(:user)          { Factory.create(:user) }

        let(:article)     { Factory.create(:article) }
        let(:own_article) { Factory.create(:article, :user => user) }

        subject { Ability.new(user) }

        it { should be_able_to(:read, article) }
        it { should be_able_to(:update, own_article) }
      end
    end


This specs generates outputs is ...


    $ bundle exec rspec -c --format d spec/models/ability_spec.rb

    Ability
      an user
        should be able to :read #<Article id: 44, title: "The Test Article 1", body: "This is test article!!", created_at: "2012-02-23 14:19:26", updated_at: "2012-02-23 14:19:26", user_id: nil>
        should be able to :update #<Article id: 45, title: "The Test Article 2", body: "This is test article!!", created_at: "2012-02-23 14:19:26", updated_at: "2012-02-23 14:19:26", user_id: 31>

    Finished in 0.26158 seconds
    2 examples, 0 failures


OMG, It's not human readable. so,let's change `let` to `named_let`.

        named_let(:article)     { Factory.create(:article) }
        named_let(:own_article) { Factory.create(:article, :user => user) }


again, execute `rspec --format d ...`


    $ bundle exec rspec -c --format d spec/models/ability_spec.rb

    Ability
      an user
        should be able to :read article
        should be able to :update own article

    Finished in 0.25375 seconds
    2 examples, 0 failures


okay, it's readable!!!

# For debugging

If the specs is fail, You will want to know original outputs of 'Object#inspect'.
But named_let hides actual outputs of "Object#inspect".

    Failures:

      1) Ability an user
         Failure/Error: it { should_not be_able_to(:update, own_article) }
           expected not to be able to :update own article


For debugging spec, if given `-d` option to rspec command or `$DEBUG` flag is true,
named_let append orignal result of `Object#inspect` to returns value.


given `-d` option, then...

    Failures:

      1) Ability an user
         Failure/Error: it { should_not be_able_to(:update, own_article) }
           expected not to be able to :update own article (#<Article id: 113, title: "The Test Article 3", body: "This is test article!!", created_at: "2012-02-24 05:53:17", updated_at: "2012-02-24 05:53:17", user_id: 90>)


NOTE:

  Requires `ruby-debug` to using `-d` option.
  run `gem install ruby-debug`.
  If your Ruby-Runtime is 1.9+, see "https://github.com/mark-moseley/ruby-debug".

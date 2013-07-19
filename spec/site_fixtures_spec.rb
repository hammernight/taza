require 'spec_helper'
require 'taza/fixture'

describe "Site Specific Fixtures" do
  before(:each) do
    Taza::Fixture.stubs(:base_path).returns('./spec/sandbox/fixtures/')

    Taza.clean_fixtures
    Taza.load_fixtures
  end

  let(:my_instance) {
    my_class = Class.new
    my_class.send(:include, Taza::Fixtures::FooSite)
    my_class.new
  }

  it "should be able to access fixtures in sub-folders" do
    my_instance.should respond_to(:bars)
    my_instance.bars(:foo).name.should eql("foo")
  end

  # bad test. it passes even if you dont load the fixtures.
  it "should not be able to access non-site-specific fixtures" do
    my_instance.bars(:foo).name.should eql("foo")
    lambda{ my_instance.foos(:gap) }.should raise_error(NoMethodError)
  end

  it "creates helper methods only when helper module is included" do
    Taza.load_fixtures
    Taza::Fixtures::FooSite.instance_methods.should be_empty

    module Boo
      include Taza::Fixtures::FooSite
    end

    Taza::Fixtures::FooSite.instance_methods.should_not be_empty
  end

  it "creates helpers only once" do
    Taza.load_fixtures
    Taza::Fixtures::FooSite.expects(:define_method).with(:bars).once
    Taza::Fixtures::FooSite.expects(:define_method).with(:profiles).once

    module Foo
      include Taza::Fixtures::FooSite
    end

    module Bar
      include Taza::Fixtures::FooSite
    end
  end

  it "loads fixtures from multiple directories" do
    Taza.load_fixtures('./spec/sandbox/other/fixtures')

    # let existing untouched
    my_instance.should respond_to(:profiles)
    my_instance.profiles(:batman).login.should eql("batman@dc.com")

    # overides a previously specified
    my_instance.should respond_to(:bars)
    my_instance.bars(:foo).name.should eql("not_foo")

    # adds unexisting fixtures
    my_instance.should respond_to(:dumb)
    my_instance.dumb(:john).address.should eql("2 folson st")
  end
end

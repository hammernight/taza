require 'spec_helper'
require 'taza/page'

describe Taza::Page do

  class ElementAndFilterContextExample < Taza::Page
    element(:sample_element) {browser}
    filter(:sample_filter, :sample_element)
    def sample_filter
      browser
    end
  end

  class RecursiveFilterExample < Taza::Page
    element(:foo) {}
    filter :sample_filter
    def sample_filter
      foo
      true
    end
  end

  it "should not enter a infinite loop if you call a filtered element inside of a filter" do
    page = RecursiveFilterExample.new
    expect(lambda { page.foo }).to_not raise_error
  end

  it "should execute an element's block with the params provided for its method" do
    Taza::Page.element(:boo){|baz| baz}
    expect(Taza::Page.new.boo("rofl")).to eql 'rofl'
    end

  it "element's name can not be nil" do
    expect{ Taza::Page.element(nil){ } }.to raise_error(Taza::ElementError)
  end

  it "should execute elements and filters in the context of the page instance" do
    page = ElementAndFilterContextExample.new
    page.browser = :something
    expect(page.sample_element).to eql :something
  end

  it "should add a filter to the classes filters" do
    expect(ElementAndFilterContextExample.filters.size).to eql 1
  end

  it "should store the block given to the element method in a method with the name of the parameter" do
    Taza::Page.element(:foo) do
      "bar"
    end
    expect(Taza::Page.new.foo).to eql 'bar'
  end

  class FilterAllElements < Taza::Page
    element(:foo) {}
    element(:apple) {}
    filter :false_filter

    def false_filter
      false
    end
  end

  it "should filter all elements if element argument is not provided" do
    expect(lambda { FilterAllElements.new.apple }).to raise_error(Taza::FilterError)
    expect(lambda { FilterAllElements.new.foo }).to raise_error(Taza::FilterError)
  end

  it "should have empty elements on a new class" do
    foo = Class::new(superclass=Taza::Page)
    expect(foo.elements).to_not be_nil
    expect(foo.elements).to be_empty
  end

  it "should have empty filters on a new class" do
    foo = Class::new(superclass=Taza::Page)
    expect(foo.filters).to_not be_nil
    expect(foo.filters).to be_empty
  end

  class FilterAnElement < Taza::Page
    attr_accessor :called_element_method
    element(:false_item) { @called_element_method = true}
    filter :false_filter, :false_item

    def false_filter
      false
    end
  end

  it "should raise a error if an elements is called and its filter returns false" do
    expect(lambda { FilterAnElement.new.false_item }).to raise_error(Taza::FilterError)
  end

  it "should not call element block if filters fail" do
    page = FilterAnElement.new
    expect(lambda { page.false_item }).to raise_error
    expect(page.called_element_method).to_not be true
  end

  it "should not allow more than one element descriptor with the same element name" do
    expect(lambda{
    class DuplicateElements < Taza::Page
      element(:foo) { true }
      element(:foo) { false }
    end
    }).to raise_error(Taza::ElementError)
  end
end

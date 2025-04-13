require 'spec_helper'
require 'taza/page'

describe "Taza Page Module" do

  class PageWithModule < ::Taza::Page

    page_module :module do
      element(:module_element) { browser }
    end

  end

  it "should execute elements in the context of their page module" do
    page = PageWithModule.new(:module)
    page.browser = :something
    expect(page.module_element).to eql :something
  end

  class AnotherPageWithModule < ::Taza::Page

    page_module :other_module do
      element(:another_module_element) { browser }
    end

  end


  it "should not execute elements that belong to a page module but accessed without it" do
    expect{ AnotherPageWithModule.new.another_module_element }.to raise_error(NoMethodError)
  end

  it "should execute elements in the context of their page module when accessed with it" do
    page = AnotherPageWithModule.new(:other_module)
    page.browser = :another_thing
    expect(page.another_module_element).to eql :another_thing
  end


  class TestPageWithModules < ::Taza::Page

    page_module :module_one do
      element(:some_module_element) { :something }
    end

    page_module :module_two do
      element(:some_module_element) { :nothing }
    end

  end

  it "should execute elements with the same name but different page modules" do
    module_one = TestPageWithModules.new(:module_one)
    module_two = TestPageWithModules.new(:module_two)
    expect(module_one.some_module_element).to eql :something
    expect(module_two.some_module_element).to eql :nothing
  end

  class PageWithMultipleModuleElements < ::Taza::Page

    page_module :module do
      element(:module_element) { :something }
      element(:another_module_element) { :nothing }
    end

  end

  it "should execute elements with the same name but different page modules" do
    page_module = PageWithMultipleModuleElements.new(:module)
    expect(page_module.module_element).to eql :something
    expect(page_module.another_module_element).to eql :nothing
  end

  class PageWithFilterAndModule < ::Taza::Page
    page_module :module do
      element(:sample_element) { :something }
    end
    filter :sample_filter, :module

    def sample_filter
      true
    end
  end

  it "should execute filters for page modules" do
    page = PageWithFilterAndModule.new(:module)
    expect(page.sample_element).to eql :something
  end

  class PageWithFalseFilterAndModule < ::Taza::Page
    page_module :module do
      element(:sample_element) { :something }
    end
    filter :false_filter, :module

    def false_filter
      false
    end
  end

  it "should raise an error for page-module filters that return false" do
    page = PageWithFalseFilterAndModule.new(:module)
    expect{ page.sample_element }.to raise_error(Taza::FilterError)
  end

  class PageWithFilterAndModuleElements < ::Taza::Page
    page_module :module do
      element(:sample_element) { :something }
    end
    page_module_filter :sample_filter, :module, :sample_element

    def sample_filter
      false
    end
  end

  it "should execute filters for elements inside page modules" do
    page = PageWithFilterAndModuleElements.new(:module)
    expect{ page.sample_element }.to raise_error(Taza::FilterError)
  end

  class PageWithFiltersAndModuleElements < ::Taza::Page
    page_module :module do
      element(:sample_element) { :something }
      element(:another_sample_element) { :something }
    end
    page_module_filter :sample_filter, :module

    def sample_filter
      true
    end

    page_module_filter :another_sample_filter, :module, :sample_element

    def another_sample_filter
      false
    end
  end

  it "should execute filters for specific and all elements inside page modules" do
    page = PageWithFiltersAndModuleElements.new(:module)
    expect{ page.sample_element }.to raise_error(Taza::FilterError)
    expect(page.another_sample_element).to eql :something
  end

  class PageWithFiltersAndModulesAndElements < ::Taza::Page
    page_module :foo_module do
      element(:sample_element) { :something }
    end
    page_module_filter :foo_filter, :foo_module

    def foo_filter
      true
    end

    page_module :bar_module do
      element(:sample_element) { :nothing }
    end
    page_module_filter :bar_filter, :bar_module

    def bar_filter
      false
    end
  end

  it "should execute page module filters for identical element names appropriately" do
    foo = PageWithFiltersAndModulesAndElements.new(:foo_module)
    expect(foo.sample_element).to eql :something
    bar = PageWithFiltersAndModulesAndElements.new(:bar_module)
    expect{ bar.sample_element }.to raise_error(Taza::FilterError)
  end

end

require 'spec_helper'
require 'extensions/string'

describe "string extensions" do
  it "should pluralize and to sym a string" do
    expect("apple".pluralize_to_sym).to eql :apples
  end

  it "should variablize words with spaces" do
    expect("foo -  BAR".variablize).to eql 'foo_bar'
  end
end

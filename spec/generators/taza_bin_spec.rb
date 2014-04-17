require 'spec_helper'
require 'rubygems'
require 'fileutils'

describe "Taza bin" do

  it 'runs from the terminal' do
    output = system("taza")
    expect(output).to be_true

  end

  it "should have an executable script" do
    pending "Not sure this is really necessary, as this is just testing if command line returns anything. It also breaks JRuby."
    path = 'spec/sandbox/generators'
    taza_bin = "#{File.expand_path(File.dirname(__FILE__)+'/../bin/taza')} #{path}"
    system("ruby -c #{taza_bin} > #{null_device}").should be_true
  end

end

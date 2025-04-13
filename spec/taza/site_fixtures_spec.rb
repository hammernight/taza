require 'spec_helper'
describe "Site Specific Fixtures" do

  before do
    stub_path = File.join(@original_directory, 'spec', 'sandbox', 'fixtures', '')
    Taza::Fixture.stubs(:base_path).returns(stub_path)
    Taza.load_fixtures
    self.class.include(Taza::Fixtures::FooSite)
  end

  it "should be able to access fixtures in sub-folders" do
    expect(bars(:foo).name).to eql 'foo'
  end

  it "should not be able to access non-site-specific fixtures" do
    expect { foos(:gap) }.to raise_error(NoMethodError)
  end

end

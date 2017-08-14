require 'spec_helper'
require 'taza/fixture'

describe Taza::Fixture do
  before :each do
    #TODO: we should generate the base project in a temp dir
    @base_path = File.join(@original_directory,'spec','sandbox','fixtures','')
  end

  it "should be able to load entries from fixtures" do
    fixture = Taza::Fixture.new
    fixture.load_fixtures_from(@base_path)
    example = fixture.get_fixture_entity(:examples,'first_example')
    expect(example.name).to eql "first"
    expect(example.price).to eql 1
  end

  it "should use the spec fixtures folder as the base path" do
    expect(Taza::Fixture.base_path).to eql './spec/fixtures/'
  end

  it "should know if a pluralized fixture of that name exists" do
    fixture = Taza::Fixture.new
    fixture.load_fixtures_from(@base_path)
    expect(fixture.pluralized_fixture_exists?('example')).to be true
    expect(fixture.pluralized_fixture_exists?('boo')).to be false
  end

  it "should be able to get all fixtures loaded excluding sub-folder fixtures" do
    fixture = Taza::Fixture.new
    fixture.load_fixtures_from(@base_path)
    expect(fixture.fixture_names).to contain_exactly(:examples, :users, :foos)
  end

  it "should be able to get specific fixture entities" do
    fixture = Taza::Fixture.new
    fixture.load_fixtures_from(@base_path)
    examples = fixture.specific_fixture_entities(:examples, ['third_example'])
    expect(examples.length).to eql 1
    expect(examples['third_example'].name).to eql 'third'
  end

  it "should not modified the fixtures when you get specific entities off a fixture" do
    fixture = Taza::Fixture.new
    fixture.load_fixtures_from(@base_path)
    previous_count = fixture.get_fixture(:examples).length
    examples = fixture.specific_fixture_entities(:examples, ['third_example'])
    expect(fixture.get_fixture(:examples).length).to eql previous_count
  end

 end

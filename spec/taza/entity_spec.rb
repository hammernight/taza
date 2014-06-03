require 'spec_helper'
require 'taza/entity'

describe Taza::Entity do
  it "should add methods for hash string keys" do
    entity = Taza::Entity.new({'apple' => 'pie'},nil)
    expect(entity).to respond_to :apple
  end

  it "should be accessible like a hash(foo[:bar])" do
    entity = Taza::Entity.new({:apple => 'pie'},nil)
    expect(entity[:apple]).to eql 'pie'
  end

  it "should be able to define methods for multiple levels" do
    entity = Taza::Entity.new({:fruits => {:apple => 'pie'} },nil)
    expect(entity.fruits.apple).to eql 'pie'
  end

  it "should be able to return a hash object" do
    entity = Taza::Entity.new({:apple => 'pie' },nil)
    expect(entity.to_hash[:apple]).to eql 'pie'
  end

  it "should be able to do string-to-symbol conversion for hash keys using to_hash" do
    entity = Taza::Entity.new({'apple' => 'pie' },nil)
    expect(entity.to_hash[:apple]).to eql 'pie'
  end

  it "should be able to do string-to-symbol conversion for hash keys" do
    entity = Taza::Entity.new({'fruits' => {'apple' => 'pie' }},nil)
    expect(entity.to_hash[:fruits][:apple]).to eql 'pie'
  end

end

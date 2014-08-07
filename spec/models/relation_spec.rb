require 'spec_helper'
include Rosemary
describe Relation do

  subject do
    Relation.new(:id         => "123",
                                :lat        => "52.2",
                                :lon        => "13.4",
                                :changeset  => "12",
                                :user       => "fred",
                                :uid        => "123",
                                :visible    => true,
                                :timestamp  => "2005-07-30T14:27:12+01:00",
                                :member     => [
                                  {"type"=>"relation", "ref"=>"1628007", "role"=>"outer"},
                                  {"type"=>"way", "ref"=>"50197015", "role"=>""}
                                ])
  end

  it { should be_valid }

  it "should have members" do
    expect(subject.members.size).to eql 2
  end

  it "should compare identity depending on tags and attributes" do
    first_relation = Relation.new('id' => 123, 'changeset' => '123', 'version' => 1, 'user' => 'horst', 'uid' => '123', 'timestamp' => '2005-07-30T14:27:12+01:00')
    first_relation.tags[:name] = 'Black horse'
    second_relation = Relation.new('id' => 123, 'changeset' => '123', 'version' => 1, 'user' => 'horst', 'uid' => '123', 'timestamp' => '2005-07-30T14:27:12+01:00')
    second_relation.tags[:name] = 'Black horse'
    expect(first_relation == second_relation).to eql true
  end

  it "should not be equal when id does not match" do
    first_relation = Relation.new('id' => 123)
    second_relation = Relation.new('id' => 234)
    expect(first_relation).not_to eql second_relation
  end

  it "should not be equal when changeset does not match" do
    first_relation = Relation.new('changeset' => 123)
    second_relation = Relation.new('changeset' => 234)
    expect(first_relation).not_to eql second_relation
  end

  it "should not be equal when version does not match" do
    first_relation = Relation.new('version' => 1)
    second_relation = Relation.new('version' => 2)
    expect(first_relation).not_to eql second_relation
  end

  it "should not be equal when user does not match" do
    first_relation = Relation.new('user' => 'horst')
    second_relation = Relation.new('user' => 'jack')
    expect(first_relation).not_to eql second_relation
  end

  it "should not be equal when uid does not match" do
    first_relation = Relation.new('uid' => 123)
    second_relation = Relation.new('uid' => 234)
    expect(first_relation).not_to eql second_relation
  end

  it "should not be equal when timestamp does not match" do
    first_relation = Relation.new('timestamp' => '2005-07-30T14:27:12+01:00')
    second_relation = Relation.new('timestamp' => '2006-07-30T14:27:12+01:00')
    expect(first_relation).not_to eql second_relation
  end

  it "should not be equal when members do not match" do
    first_relation = Relation.new('id' => 123)
    first_relation.members << 1
    first_relation.members << 2
    second_relation = Relation.new('id' => 123)
    second_relation.members << 1
    second_relation.members << 3
    expect(first_relation).not_to eql second_relation
  end

  it "should not be equal when tags do not match" do
    first_relation = Relation.new('id' => 123)
    first_relation.tags[:name] = 'black horse'
    second_relation = Relation.new('id' => 123)
    second_relation.tags[:name] = 'white horse'
    expect(first_relation).not_to eql second_relation
  end

end
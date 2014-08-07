require 'spec_helper'
include Rosemary
describe Changeset do

  let :changeset do
    Changeset.new( :id => "123",
                                  :user => "fred",
                                  :uid => "123",
                                  :created_at => "2008-11-08T19:07:39+01:00",
                                  :open => "true",
                                  :min_lat => "52.2",
                                  :max_lat => "52.3",
                                  :min_lon => "13.4",
                                  :max_lon => "13.5",
                                  :tags    => { :comment => 'A bloody comment' })
  end

  context 'attributes' do

    subject { changeset }

    it "should have an id attribute set from attributes" do
      expect(subject.id).to eql(123)
    end

    it "should have a user attributes set from attributes" do
      expect(subject.user).to eql("fred")
    end

    it "should have an uid attribute set from attributes" do
      expect(subject.uid).to eql(123)
    end

    it "should have a changeset attributes set from attributes" do
      expect(subject).to be_open
    end

    it "should have a min_lat attribute set from attributes" do
      expect(subject.min_lat).to eql(52.2)
    end

    it "should have a min_lon attribute set from attributes" do
      expect(subject.min_lon).to eql(13.4)
    end

    it "should have a max_lat attribute set from attributes" do
      expect(subject.max_lat).to eql(52.3)
    end

    it "should have a max_lon attribute set from attributes" do
      expect(subject.max_lon).to eql(13.5)
    end

    it "should have a created_at attribute set from attributes" do
      expect(subject.created_at).to eql Time.parse('2008-11-08T19:07:39+01:00')
    end

    it "should have a comment attribute set from attributes" do
      expect(subject.tags['comment']).to eql 'A bloody comment'
    end
  end

  context 'xml representation' do

    subject { changeset.to_xml }

    it "should have an id attribute within xml representation" do
      expect(subject).to have_xml "//changeset[@id='123']"
    end

    it "should have a user attribute within xml representation" do
      expect(subject).to have_xml "//changeset[@user='fred']"
    end

    it "should have an uid attribute within xml representation" do
      expect(subject).to have_xml "//changeset[@uid='123']"
    end

    it "should have an open attribute within xml representation" do
      expect(subject).to have_xml "//changeset[@open='true']"
    end

    it "should have a min_lat attribute within xml representation" do
      expect(subject).to have_xml "//changeset[@min_lat='52.2']"
    end

    it "should have a min_lon attribute within xml representation" do
      expect(subject).to have_xml "//changeset[@min_lon='13.4']"
    end

    it "should have a max_lat attribute within xml representation" do
      expect(subject).to have_xml "//changeset[@max_lat='52.3']"
    end

    it "should have a max_lon attribute within xml representation" do
      expect(subject).to have_xml "//changeset[@max_lon='13.5']"
    end

    it "should have a created_at attribute within xml representation" do
      expect(subject).to have_xml "//changeset[@created_at=\'#{Time.parse('2008-11-08T19:07:39+01:00')}\']"
    end

    it "should have a comment tag within xml representation" do
      expect(subject).to have_xml "//tag[@k='comment'][@v='A bloody comment']"
    end

  end
end
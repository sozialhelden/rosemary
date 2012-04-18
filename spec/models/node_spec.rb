require 'spec_helper'
include Rosemary

describe Node do

  subject do
    Node.new(:id         => "123",
                            :lat        => "52.2",
                            :lon        => "13.4",
                            :changeset  => "12",
                            :user       => "fred",
                            :uid        => "123",
                            :visible    => true,
                            :timestamp  => "2005-07-30T14:27:12+01:00")
  end

  it { should be_valid }

  it "should be invalid without lat, lon" do
    subject.lat = nil
    subject.lon = nil
    subject.should_not be_valid
  end

  it "does not modify the hash passed into constructor" do
    h = { :lat => 13.9, :lon => 54.1 }.freeze
    lambda { Node.new(h) }.should_not raise_error
  end

  it "should not be valid when using to large lat value" do
    subject.lat = 181
    subject.should_not be_valid
  end

  it "should not be valid when using to large lat value" do
    subject.lon = 91
    subject.should_not be_valid
  end

  it "should have an id attribute set from attributes" do
    subject.id.should eql(123)
  end

  it "should have an id attribute within xml representation" do
    subject.to_xml.should match /id=\"123\"/
  end

  it "should have a lat attribute set from attributes" do
    subject.lat.should eql(52.2)
  end

  it "should have a lat attribute within xml representation" do
    subject.to_xml.should match /lat=\"52.2\"/
  end

  it "should have a lon attribute set from attributes" do
    subject.lon.should eql(13.4)
  end

  it "should have a lon attribute within xml representation" do
    subject.to_xml.should match /lon=\"13.4\"/
  end

  it "should have a user attributes set from attributes" do
    subject.user.should eql("fred")
  end

  it "should have a user attribute within xml representation" do
    subject.to_xml.should match /user=\"fred\"/
  end

  it "should have a changeset attributes set from attributes" do
    subject.changeset.should eql(12)
  end

  it "should have a changeset attribute within xml representation" do
    subject.to_xml.should match /changeset=\"12\"/
  end

  it "should have a uid attribute set from attributes" do
    subject.uid.should eql(123)
  end

  it "should have a uid attribute within xml representation" do
    subject.to_xml.should match /uid=\"123\"/
  end

  it "should produce xml" do
    subject.add_tags(:wheelchair => 'yes')
    subject.to_xml.should match /k=\"wheelchair\"/
    subject.to_xml.should match /v=\"yes\"/
  end

  it "should not add tags with empty value to xml" do
    subject.add_tags(:wheelchair => '')
    subject.to_xml.should_not match /k=\"wheelchair\"/
  end

  it "should properly escape ampersands" do
    subject.name = "foo & bar"
    subject.to_xml.should match "foo &amp; bar"
  end
end
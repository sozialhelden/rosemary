require 'spec_helper'

describe 'Rosemary::Changeset' do

  let :changeset do
    Rosemary::Changeset.new( :id => "123",
                                  :user => "fred",
                                  :uid => "123",
                                  :created_at => "2008-11-08T19:07:39+01:00",
                                  :open => "true",
                                  :min_lat => "52.2",
                                  :max_lat => "52.3",
                                  :min_lon => "13.4",
                                  :max_lon => "13.5")
  end

  it "should have an id attribute set from attributes" do
    changeset.id.should eql(123)
  end

  it "should have an id attribute within xml representation" do
    changeset.to_xml.should match /id=\"123\"/
  end

  it "should have a user attributes set from attributes" do
    changeset.user.should eql("fred")
  end

  it "should have a user attribute within xml representation" do
    changeset.to_xml.should match /user=\"fred\"/
  end

  it "should have an uid attribute set from attributes" do
    changeset.uid.should eql(123)
  end

  it "should have an uid attribute within xml representation" do
    changeset.to_xml.should match /uid=\"123\"/
  end

  it "should have a changeset attributes set from attributes" do
    changeset.should be_open
  end

  it "should have an open attribute within xml representation" do
    changeset.to_xml.should match /open=\"true\"/
  end

  it "should have a min_lat attribute set from attributes" do
    changeset.min_lat.should eql(52.2)
  end

  it "should have a min_lat attribute within xml representation" do
    changeset.to_xml.should match /min_lat=\"52.2\"/
  end

  it "should have a min_lon attribute set from attributes" do
    changeset.min_lon.should eql(13.4)
  end

  it "should have a min_lon attribute within xml representation" do
    changeset.to_xml.should match /min_lon=\"13.4\"/
  end

  it "should have a max_lat attribute set from attributes" do
    changeset.max_lat.should eql(52.3)
  end

  it "should have a max_lat attribute within xml representation" do
    changeset.to_xml.should match /max_lat=\"52.3\"/
  end

  it "should have a max_lon attribute set from attributes" do
    changeset.max_lon.should eql(13.5)
  end

  it "should have a max_lon attribute within xml representation" do
    changeset.to_xml.should match /max_lon=\"13.5\"/
  end

  it "should have a created_at attribute set from attributes" do
    changeset.created_at.should eql Time.parse('2008-11-08T19:07:39+01:00')
  end

  it "should have a created_at attribute within xml representation" do
    changeset.to_xml.should match /created_at=\"/
  end


end
require 'spec_helper'
include Rosemary
describe Way do

  def valid_fake_way
    way=<<-EOF
    <osm>
     <way id="1234" version="142" changeset="12" user="fred" uid="123" visible="true" timestamp="2005-07-30T14:27:12+01:00">
       <tag k="note" v="Just a way"/>
       <nd ref="15735248"/>
       <nd ref="169269997"/>
       <nd ref="169270001"/>
       <nd ref="15735251"/>
       <nd ref="15735252"/>
       <nd ref="15735253"/>
       <nd ref="15735250"/>
       <nd ref="15735247"/>
       <nd ref="15735246"/>
       <nd ref="15735249"/>
       <nd ref="15735248"/>
     </way>
    </osm>
    EOF
  end

  subject do
    @way ||= Way.from_xml(valid_fake_way)
  end

  it "should have 4 nodes" do
    subject.nodes.size.should eql 11
    subject.nodes.first.should eql 15735248
  end

  it "should have node referenzes in xml representation" do
    subject.to_xml.should match /ref=\"15735248\"/
  end


  it "should have an id attribute set from attributes" do
    subject.id.should eql(1234)
  end

  it "should have an id attribute within xml representation" do
    subject.to_xml.should match /id=\"1234\"/
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

  it "should have a version attribute for osm tag" do
    subject.to_xml.should match /version=\"0.6\"/
  end

  it "should have a generator attribute for osm tag" do
    subject.to_xml.should match /generator=\"rosemary v/
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
end
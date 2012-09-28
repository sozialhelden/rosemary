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

  it "should compare identity depending on tags and attributes" do
    first_way = Way.new('id' => 123, 'changeset' => '123', 'version' => 1, 'user' => 'horst', 'uid' => '123', 'timestamp' => '2005-07-30T14:27:12+01:00')
    first_way.tags[:name] = 'Black horse'
    second_way = Way.new('id' => 123, 'changeset' => '123', 'version' => 1, 'user' => 'horst', 'uid' => '123', 'timestamp' => '2005-07-30T14:27:12+01:00')
    second_way.tags[:name] = 'Black horse'
    first_way.should == second_way
  end

  it "should not be equal when id does not match" do
    first_way = Way.new('id' => 123)
    second_way = Way.new('id' => 234)
    first_way.should_not == second_way
  end

  it "should not be equal when changeset does not match" do
    first_way = Way.new('changeset' => 123)
    second_way = Way.new('changeset' => 234)
    first_way.should_not == second_way
  end

  it "should not be equal when version does not match" do
    first_way = Way.new('version' => 1)
    second_way = Way.new('version' => 2)
    first_way.should_not == second_way
  end

  it "should not be equal when user does not match" do
    first_way = Way.new('user' => 'horst')
    second_way = Way.new('user' => 'jack')
    first_way.should_not == second_way
  end

  it "should not be equal when uid does not match" do
    first_way = Way.new('uid' => 123)
    second_way = Way.new('uid' => 234)
    first_way.should_not == second_way
  end

  it "should not be equal when timestamp does not match" do
    first_way = Way.new('timestamp' => '2005-07-30T14:27:12+01:00')
    second_way = Way.new('timestamp' => '2006-07-30T14:27:12+01:00')
    first_way.should_not == second_way
  end

  it "should not be equal when nodes do not match" do
    first_way = Way.new('id' => 123)
    first_way.nodes << 1
    first_way.nodes << 2
    second_way = Way.new('id' => 123)
    second_way.nodes << 1
    second_way.nodes << 3
    first_way.should_not == second_way
  end

  it "should not be equal when tags do not match" do
    first_way = Way.new('id' => 123)
    first_way.tags[:name] = 'black horse'
    second_way = Way.new('id' => 123)
    second_way.tags[:name] = 'white horse'
    first_way.should_not == second_way
  end
end
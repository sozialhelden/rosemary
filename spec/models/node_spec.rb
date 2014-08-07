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
    expect(subject).not_to be_valid
  end

  it "does not modify the hash passed into constructor" do
    h = { :lat => 13.9, :lon => 54.1 }.freeze
    expect { Node.new(h) }.not_to raise_exception
  end

  it "should not be valid when using to large lat value" do
    subject.lat = 181
    expect(subject).not_to be_valid
  end

  it "should not be valid when using to large lat value" do
    subject.lon = 91
    expect(subject).not_to be_valid
  end

  it "should have an id attribute set from attributes" do
    expect(subject.id).to eql(123)
  end

  it "should have an id attribute within xml representation" do
    expect(subject.to_xml).to match /id=\"123\"/
  end

  it "should have a lat attribute set from attributes" do
    expect(subject.lat).to eql(52.2)
  end

  it "should have a lat attribute within xml representation" do
    expect(subject.to_xml).to match /lat=\"52.2\"/
  end

  it "should have a lon attribute set from attributes" do
    expect(subject.lon).to eql(13.4)
  end

  it "should have a lon attribute within xml representation" do
    expect(subject.to_xml).to match /lon=\"13.4\"/
  end

  it "should have a user attributes set from attributes" do
    expect(subject.user).to eql("fred")
  end

  it "should have a user attribute within xml representation" do
    expect(subject.to_xml).to match /user=\"fred\"/
  end

  it "should have a changeset attributes set from attributes" do
    expect(subject.changeset).to eql(12)
  end

  it "should have a changeset attribute within xml representation" do
    expect(subject.to_xml).to match /changeset=\"12\"/
  end

  it "should have a uid attribute set from attributes" do
    expect(subject.uid).to eql(123)
  end

  it "should have a uid attribute within xml representation" do
    expect(subject.to_xml).to match /uid=\"123\"/
  end

  it "should have a version attribute for osm tag" do
    expect(subject.to_xml).to match /version=\"0.6\"/
  end

  it "should have a generator attribute for osm tag" do
    expect(subject.to_xml).to match /generator=\"rosemary v/
  end

  it "should produce xml" do
    subject.add_tags(:wheelchair => 'yes')
    expect(subject.to_xml).to match /k=\"wheelchair\"/
    expect(subject.to_xml).to match /v=\"yes\"/
  end

  it "should not add tags with empty value to xml" do
    subject.add_tags(:wheelchair => '')
    expect(subject.to_xml).not_to match /k=\"wheelchair\"/
  end

  it "should properly escape ampersands" do
    subject.name = "foo & bar"
    expect(subject.to_xml).to match "foo &amp; bar"
  end

  it "should properly strip leading and trailing whitespace" do
    subject.name = " Allice and Bob "
    expect(subject.to_xml).to match "\"Allice and Bob\""
  end

  it "should compare identity depending on tags and attributes" do
    first_node = Node.new('id' => 123, 'changeset' => '123', 'version' => 1, 'user' => 'horst', 'uid' => '123', 'timestamp' => '2005-07-30T14:27:12+01:00')
    first_node.tags[:name] = 'Black horse'
    second_node = Node.new('id' => 123, 'changeset' => '123', 'version' => 1, 'user' => 'horst', 'uid' => '123', 'timestamp' => '2005-07-30T14:27:12+01:00')
    second_node.tags[:name] = 'Black horse'
    expect(first_node <=> second_node).to eql 0
  end

  it "should not be equal when id does not match" do
    first_node = Node.new('id' => 123)
    second_node = Node.new('id' => 234)
    expect(first_node).not_to eql second_node
  end

  it "should not be equal when changeset does not match" do
    first_node = Node.new('changeset' => 123)
    second_node = Node.new('changeset' => 234)
    expect(first_node).not_to eql second_node
  end

  it "should not be equal when version does not match" do
    first_node = Node.new('version' => 1)
    second_node = Node.new('version' => 2)
    expect(first_node).not_to eql second_node
  end

  it "should not be equal when user does not match" do
    first_node = Node.new('user' => 'horst')
    second_node = Node.new('user' => 'jack')
    expect(first_node).not_to eql second_node
  end

  it "should not be equal when uid does not match" do
    first_node = Node.new('uid' => 123)
    second_node = Node.new('uid' => 234)
    expect(first_node).not_to eql second_node
  end

  it "should not be equal when timestamp does not match" do
    first_node = Node.new('timestamp' => '2005-07-30T14:27:12+01:00')
    second_node = Node.new('timestamp' => '2006-07-30T14:27:12+01:00')
    expect(first_node).not_to eql second_node
  end

  it "should not be equal when tags do not match" do
    first_node = Node.new('id' => 123)
    first_node.tags[:name] = 'black horse'
    second_node = Node.new('id' => 123)
    second_node.tags[:name] = 'white horse'
    expect(first_node).not_to eql second_node
  end

  it "should be ok to pass tags with emtpy value" do
    expect {
      subject.add_tags({"wheelchair_description"=>"", "type"=>"convenience",
        "street"=>nil, "name"=>"Kochhaus", "wheelchair"=>nil, "postcode"=>nil,
        "phone"=>nil, "city"=>nil, "website"=>nil, "lon"=>"13.35598468780518",
        "lat"=>"52.48627569798567", "housenumber"=>nil})
    }.not_to raise_exception
  end
end
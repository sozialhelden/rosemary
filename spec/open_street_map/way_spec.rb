require 'osm-client'

describe 'OpenStreetMap::Way' do

  let :way do
    OpenStreetMap::Way.new( :id         => "123",
                            :changeset  => "12",
                            :user       => "fred",
                            :uid        => "123",
                            :visible    => true,
                            :timestamp  => "2005-07-30T14:27:12+01:00",
                            :nd      => [{:ref =>1}, {:ref =>2}, {:ref => 3}, {:ref => 4}])
  end

  it "should have 4 nodes" do
    way.nodes.size.should eql 4
    way.nodes.first.should eql 1
  end

  it "should have node referenzes in xml representation" do
    way.to_xml.should match /ref=\"1\"/
  end


  it "should have an id attribute set from attributes" do
    way.id.should eql(123)
  end

  it "should have an id attribute within xml representation" do
    way.to_xml.should match /id=\"123\"/
  end

  it "should have a user attributes set from attributes" do
    way.user.should eql("fred")
  end

  it "should have a user attribute within xml representation" do
    way.to_xml.should match /user=\"fred\"/
  end

  it "should have a changeset attributes set from attributes" do
    way.changeset.should eql(12)
  end

  it "should have a changeset attribute within xml representation" do
    way.to_xml.should match /changeset=\"12\"/
  end

  it "should have a uid attribute set from attributes" do
    way.uid.should eql(123)
  end

  it "should have a uid attribute within xml representation" do
    way.to_xml.should match /uid=\"123\"/
  end

  it "should produce xml" do
    way.add_tags(:wheelchair => 'yes')
    way.to_xml.should match /k=\"wheelchair\"/
    way.to_xml.should match /v=\"yes\"/
  end
end
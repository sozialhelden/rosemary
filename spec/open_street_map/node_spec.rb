require 'osm'

describe 'OpenStreetMap::Node' do

  let :node do
    OpenStreetMap::Node.new(:id         => "123",
                            :lat        => "52.2",
                            :lon        => "13.4",
                            :changeset  => "12",
                            :user       => "fred",
                            :uid        => "123",
                            :visible    => true,
                            :timestamp  => "2005-07-30T14:27:12+01:00")
  end

  it "should have an id attribute set from attributes" do
    node.id.should eql(123)
  end

  it "should have an id attribute within xml representation" do
    node.to_xml.should match /id=\"123\"/
  end

  it "should have a lat attribute set from attributes" do
    node.lat.should eql(52.2)
  end

  it "should have a lat attribute within xml representation" do
    node.to_xml.should match /lat=\"52.2\"/
  end

  it "should have a lon attribute set from attributes" do
    node.lon.should eql(13.4)
  end

  it "should have a lon attribute within xml representation" do
    node.to_xml.should match /lon=\"13.4\"/
  end

  it "should have a user attributes set from attributes" do
    node.user.should eql("fred")
  end

  it "should have a user attribute within xml representation" do
    node.to_xml.should match /user=\"fred\"/
  end

  it "should have a changeset attributes set from attributes" do
    node.changeset.should eql(12)
  end

  it "should have a changeset attribute within xml representation" do
    node.to_xml.should match /changeset=\"12\"/
  end

  it "should have a uid attribute set from attributes" do
    node.uid.should eql(123)
  end

  it "should have a uid attribute within xml representation" do
    node.to_xml.should match /uid=\"123\"/
  end

  it "should produce xml" do
    node.add_tags(:wheelchair => 'yes')
    node.to_xml.should match /k=\"wheelchair\"/
    node.to_xml.should match /v=\"yes\"/
  end
end
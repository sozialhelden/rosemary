require 'open_street_map'

describe 'OpenStreetMap::Node' do

  let :node do
    OpenStreetMap::Node.new(:id => "123", :lat => "52.2", :lon => "13.4", :changeset => "12", :user => "fred", :uid => "123", :visible => true, :timestamp => "2005-07-30T14:27:12+01:00")
  end

  it "should have an id attribute set from attributes" do
    node.id.should eql(123)
  end

  it "should have a lat attribute set from attributes" do
    node.lat.should eql(52.2)
  end

  it "should have a lon attribute set from attributes" do
    node.lon.should eql(13.4)
  end

  it "should have a user attributes set from attributes" do
    node.user.should eql("fred")
  end

  it "should have a changeset attributes set from attributes" do
    node.changeset.should eql(12)
  end

end
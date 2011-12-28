require 'open_street_map'

describe 'OpenStreetMap::Node' do

  let :node do
    OpenStreetMap::Node.new
  end

  it "should have a lat attribute" do
    node.lat.should_not be_nil
  end
end
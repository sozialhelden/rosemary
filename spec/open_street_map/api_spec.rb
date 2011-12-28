require 'webmock/rspec'
require 'open_street_map'

describe 'OpenStreetMap::Api' do

  before do
    WebMock.disable_net_connect!
  end

  def valid_fake_node
    node=<<-EOF
    <osm>
     <node id="123" lat="51.2" lon="13.4" version="142" changeset="12" user="fred" uid="123" visible="true" timestamp="2005-07-30T14:27:12+01:00">
       <tag k="note" v="Just a node"/>
     </node>
    </osm>
    EOF
  end

  it "should extract lat from xml" do
    stub_request(:get, "http://www.openstreetmap.org/api/0.6/node/1234").to_return(:status => 200, :body => valid_fake_node, :headers => {})
    node = OpenStreetMap::Api.get_object('node', 1234)
    node.lat.should eql(51.2)
  end

  it "should extract lon from xml" do
    stub_request(:get, "http://www.openstreetmap.org/api/0.6/node/1234").to_return(:status => 200, :body => valid_fake_node, :headers => {})
    node = OpenStreetMap::Api.get_object('node', 1234)
    node.lon.should eql(13.4)
  end

end
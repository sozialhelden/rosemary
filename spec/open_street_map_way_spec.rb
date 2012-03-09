require 'webmock/rspec'
require 'openstreetmap'

describe 'OpenStreetMap' do

  before do
    WebMock.disable_net_connect!
  end

  let :osm do
    OpenStreetMap::Api.new
  end

  describe '::Way' do

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

    describe '#find:' do

      it "should build a Way from API response via get_way" do
        stub_request(:get, "http://www.openstreetmap.org/api/0.6/way/1234").to_return(:status => 200, :body => valid_fake_way, :headers => {'Content-Type' => 'application/xml'})
        way = osm.find_way(1234)
        way.class.should eql OpenStreetMap::Way
        way.nodes.should include(15735246)
      end
    end

    describe '#create:' do
    end

    describe '#update:' do
    end

    describe '#delete:' do
    end
  end
end
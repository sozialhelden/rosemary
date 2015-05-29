require 'spec_helper'
include Rosemary
describe BoundingBox do

  let :osm do
    Api.new
  end

  def valid_fake_boundary
    boundary=<<-EOF
    <osm>
     <bounds minlat="37.3855400" minlon="-122.0359880" maxlat="37.4116770" maxlon="-122.0094800"/>
     <node id="3147580094" visible="true" version="1" changeset="26302066" timestamp="2014-10-24T15:12:05Z" user="matthieun" uid="595221" lat="37.3872247" lon="-122.0216695"/>
     <node id="3147580093" visible="true" version="1" changeset="26302066" timestamp="2014-10-24T15:12:05Z" user="matthieun" uid="595221" lat="37.3872110" lon="-122.0216157"/>
     <node id="3147580084" visible="true" version="1" changeset="26302066" timestamp="2014-10-24T15:12:05Z" user="matthieun" uid="595221" lat="37.3870427" lon="-122.0216838"/>
     <node id="3147580085" visible="true" version="1" changeset="26302066" timestamp="2014-10-24T15:12:05Z" user="matthieun" uid="595221" lat="37.3870564" lon="-122.0217376"/>
     <node id="3147580103" visible="true" version="1" changeset="26302066" timestamp="2014-10-24T15:12:05Z" user="matthieun" uid="595221" lat="37.3873678" lon="-122.0218229"/>
     <node id="3147580098" visible="true" version="1" changeset="26302066" timestamp="2014-10-24T15:12:05Z" user="matthieun" uid="595221" lat="37.3872486" lon="-122.0213856"/>
     <node id="3147580089" visible="true" version="1" changeset="26302066" timestamp="2014-10-24T15:12:05Z" user="matthieun" uid="595221" lat="37.3871661" lon="-122.0214213"/>
     <node id="3147580092" visible="true" version="1" changeset="26302066" timestamp="2014-10-24T15:12:05Z" user="matthieun" uid="595221" lat="37.3871896" lon="-122.0215072"/>
     <node id="3147580077" visible="true" version="1" changeset="26302066" timestamp="2014-10-24T15:12:05Z" user="matthieun" uid="595221" lat="37.3869174" lon="-122.0216248"/>
     <node id="3147580078" visible="true" version="1" changeset="26302066" timestamp="2014-10-24T15:12:05Z" user="matthieun" uid="595221" lat="37.3869465" lon="-122.0217314"/>
     <node id="3147580081" visible="true" version="1" changeset="26302066" timestamp="2014-10-24T15:12:05Z" user="matthieun" uid="595221" lat="37.3870081" lon="-122.0217048"/>
     <node id="3147580083" visible="true" version="1" changeset="26302066" timestamp="2014-10-24T15:12:05Z" user="matthieun" uid="595221" lat="37.3870225" lon="-122.0217578"/>
     <node id="3147580079" visible="true" version="1" changeset="26302066" timestamp="2014-10-24T15:12:05Z" user="matthieun" uid="595221" lat="37.3869654" lon="-122.0217825"/>
     <node id="3147580080" visible="true" version="1" changeset="26302066" timestamp="2014-10-24T15:12:05Z" user="matthieun" uid="595221" lat="37.3869935" lon="-122.0218854"/>
     <node id="3147580099" visible="true" version="1" changeset="26302066" timestamp="2014-10-24T15:12:05Z" user="matthieun" uid="595221" lat="37.3872596" lon="-122.0217704"/>
     <node id="3147580101" visible="true" version="1" changeset="26302066" timestamp="2014-10-24T15:12:05Z" user="matthieun" uid="595221" lat="37.3872838" lon="-122.0218592"/>
     <way id="309425057" visible="true" version="1" changeset="26302066" timestamp="2014-10-24T15:12:06Z" user="matthieun" uid="595221">
      <nd ref="3147580094"/>
      <nd ref="3147580093"/>
      <nd ref="3147580084"/>
      <nd ref="3147580085"/>
      <nd ref="3147580094"/>
     </way>
    <way id="309425054" visible="true" version="1" changeset="26302066" timestamp="2014-10-24T15:12:06Z" user="matthieun" uid="595221">
      <nd ref="3147580103"/>
      <nd ref="3147580098"/>
      <nd ref="3147580089"/>
      <nd ref="3147580092"/>
      <nd ref="3147580077"/>
      <nd ref="3147580078"/>
      <nd ref="3147580081"/>
      <nd ref="3147580083"/>
      <nd ref="3147580079"/>
      <nd ref="3147580080"/>
      <nd ref="3147580099"/>
      <nd ref="3147580101"/>
      <nd ref="3147580103"/>
     </way>
     <relation id="4133073" visible="true" version="1" changeset="26302066" timestamp="2014-10-24T15:12:07Z" user="matthieun" uid="595221">
      <member type="way" ref="309425057" role="inner"/>
      <member type="way" ref="309425054" role="outer"/>
      <tag k="building" v="residential"/>
      <tag k="type" v="multipolygon"/>
     </relation>
    </osm>
    EOF
  end

  describe '#find:' do
    it "should find an array of Ways, Nodes and Relations from the API response via find_boundary" do
      stub_request(:get, "http://www.openstreetmap.org/api/0.6/map?bbox=-122.035988,37.38554,-122.00948,37.411677").to_return(:status => 200, :body => valid_fake_boundary, :headers => {'Content-Type' => 'application/xml'})
      boundary = osm.find_bounding_box(-122.035988,37.38554,-122.00948,37.411677)

      expect(boundary.class).to eql BoundingBox
      expect(boundary.nodes).to include(Rosemary::Node.new({"id"=>"3147580094", "visible"=>"true", "version"=>"1", "changeset"=>"26302066", "timestamp"=>"2014-10-24T15:12:05Z", "user"=>"matthieun", "uid"=>"595221", "lat"=>"37.3872247", "lon"=>"-122.0216695"}))
      expect(boundary.ways.map { |it| it.id }).to include(309425054)
      expect(boundary.relations.map { |it| it.id }).to include(4133073)

      parsed_relation = boundary.relations.first

      expect(parsed_relation.members.length).to equal(2)
      expect(parsed_relation.tags.length).to equal(2)
      expect(boundary.minlat).to be_within(0.00001).of(37.3855400)
      expect(boundary.minlon).to be_within(0.00001).of(-122.0359880)
      expect(boundary.maxlat).to be_within(0.00001).of(37.4116770)
      expect(boundary.maxlon).to be_within(0.00001).of(-122.0094800)
    end
  end

  describe '#xml:' do
    it "should produce an xml that is equivalent to the parsed one" do
      stub_request(:get, "http://www.openstreetmap.org/api/0.6/map?bbox=-122.035988,37.38554,-122.00948,37.411677").to_return(:status => 200, :body => valid_fake_boundary, :headers => {'Content-Type' => 'application/xml'})
      boundary = osm.find_bounding_box(-122.035988,37.38554,-122.00948,37.411677)

      xml = boundary.to_xml
      reparsed_boundary = Parser.call(xml, :xml)

      expect(reparsed_boundary.minlat).to eql(boundary.minlat)
      expect(reparsed_boundary.nodes.length).to eql(boundary.nodes.length)
      expect(reparsed_boundary.nodes.first.lat).to eql(boundary.nodes.first.lat)
      expect(reparsed_boundary.ways.length).to eql(boundary.ways.length)
      expect(reparsed_boundary.ways.first.nodes.first).to eql(boundary.ways.first.nodes.first)
      expect(reparsed_boundary.relations.length).to eql(boundary.relations.length)
      expect(reparsed_boundary.relations.first.tags.first).to eql(boundary.relations.first.tags.first)
    end

  end
end

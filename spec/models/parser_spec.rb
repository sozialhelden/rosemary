require 'spec_helper'
include Rosemary
describe Parser do
  context "xml" do
    it "parses ampersands correctly" do

      node_xml =<<-EOF
      <osm>
       <node id="123" lat="51.2" lon="13.4" version="42" changeset="12" user="fred" uid="123" visible="true" timestamp="2005-07-30T14:27:12+01:00">
         <tag k="note" v="Just a node"/>
         <tag k="amenity" v="bar" />
         <tag k="name" v="The rose &#38; the pony" />
       </node>
      </osm>
      EOF

      n = Parser.call(node_xml, :xml)
      expect(n.name).to eql "The rose & the pony"



    end

    it "parses empty set of permissions" do
      permissions_xml =<<-EOF
      <osm version="0.6" generator="OpenStreetMap Server">
        <permissions>
        </permissions>
      </osm>
      EOF

      permissions = Parser.call(permissions_xml, :xml)
      expect(permissions.raw).to be_empty
    end

    it "parses permissions" do
      permissions_xml =<<-EOF
      <osm version="0.6" generator="OpenStreetMap Server">
        <permissions>
        <permission name="allow_read_prefs" />
        <permission name="allow_write_api" />
        </permissions>
      </osm>
      EOF

      permissions = Parser.call(permissions_xml, :xml)
      expect(permissions.raw.sort).to eql %w(allow_read_prefs allow_write_api)

      expect(permissions.allow_write_api?).to eql true
      expect(permissions.allow_read_prefs?).to eql true
      expect(permissions.allow_write_prefs?).to eql false
    end
  end

end
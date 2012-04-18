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
      n.name.should == "The rose & the pony"



    end
  end
end
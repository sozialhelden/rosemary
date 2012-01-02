require 'osm-client'

describe 'OpenStreetMap::Changeset' do

  def valid_fake_changeset
    changeset=<<-EOF
    <osm>
      <changeset id="10" user="fred" uid="123" created_at="2008-11-08T19:07:39+01:00" open="true" min_lon="7.0191821" min_lat="49.2785426" max_lon="7.0197485" max_lat="49.2793101">
        <tag k="created_by" v="JOSM 1.61"/>
        <tag k="comment" v="Just adding some streetnames"/>
     </changeset>
    </osm>
    EOF
  end


  let :changeset do
    OpenStreetMap::Changeset.new(:id => "123", :user => "fred", :uid => "123", :created_at => "2008-11-08T19:07:39+01:00", :open => "true", :min_lat => "52.2", :min_lon => "13.4")
  end

  it "should have an id attribute set from attributes" do
    changeset.id.should eql(123)
  end

  it "should have a lat attribute set from attributes" do
    changeset.min_lat.should eql(52.2)
  end

  it "should have a lon attribute set from attributes" do
    changeset.min_lon.should eql(13.4)
  end

  it "should have a user attributes set from attributes" do
    changeset.user.should eql("fred")
  end

  it "should have a changeset attributes set from attributes" do
    changeset.should be_open
  end

end
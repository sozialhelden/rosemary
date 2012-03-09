require 'openstreetmap'

describe 'OpenStreetMap::Way' do

  subject do
    @way ||= OpenStreetMap::Way.new(  :id         => "123",
                                      :changeset  => "12",
                                      :user       => "fred",
                                      :uid        => "123",
                                      :visible    => true,
                                      :timestamp  => "2005-07-30T14:27:12+01:00")
    @way  << [1, 2, 3, 4]
    @way
  end

  it "should have 4 nodes" do
    subject.nodes.size.should eql 4
    subject.nodes.first.should eql 1
  end

  it "should have node referenzes in xml representation" do
    subject.to_xml.should match /ref=\"1\"/
  end


  it "should have an id attribute set from attributes" do
    subject.id.should eql(123)
  end

  it "should have an id attribute within xml representation" do
    subject.to_xml.should match /id=\"123\"/
  end

  it "should have a user attributes set from attributes" do
    subject.user.should eql("fred")
  end

  it "should have a user attribute within xml representation" do
    subject.to_xml.should match /user=\"fred\"/
  end

  it "should have a changeset attributes set from attributes" do
    subject.changeset.should eql(12)
  end

  it "should have a changeset attribute within xml representation" do
    subject.to_xml.should match /changeset=\"12\"/
  end

  it "should have a uid attribute set from attributes" do
    subject.uid.should eql(123)
  end

  it "should have a uid attribute within xml representation" do
    subject.to_xml.should match /uid=\"123\"/
  end

  it "should produce xml" do
    subject.add_tags(:wheelchair => 'yes')
    subject.to_xml.should match /k=\"wheelchair\"/
    subject.to_xml.should match /v=\"yes\"/
  end
end
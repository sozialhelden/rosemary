require 'spec_helper'
include Rosemary

describe Changeset do

  before do
    WebMock.disable_net_connect!
  end

  let :osm do
    Api.new
  end

  let :auth_osm do
    Api.new(BasicAuthClient.new('a_username', 'a_password'))
  end

  def valid_fake_user
    user=<<-EOF
    <osm version="0.6" generator="OpenStreetMap server">
     <user display_name="Max Muster" account_created="2006-07-21T19:28:26Z" id="1234">
       <home lat="49.4733718952806" lon="8.89285988577866" zoom="3"/>
       <description>The description of your profile</description>
       <languages>
         <lang>de-DE</lang>
         <lang>de</lang>
         <lang>en-US</lang>
         <lang>en</lang>
       </languages>
     </user>
    </osm>
    EOF
  end

  def missing_changeset
    changeset=<<-EOF
    <osm version="0.6" generator="OpenStreetMap server"/>
    EOF
  end

  def single_changeset
    changeset=<<-EOF
    <osm version="0.6" generator="OpenStreetMap server">
      <changeset id="10" user="fred" uid="123" created_at="2008-11-08T19:07:39+01:00" open="true" min_lon="7.0191821" min_lat="49.2785426" max_lon="7.0197485" max_lat="49.2793101">
        <tag k="created_by" v="JOSM 1.61"/>
        <tag k="comment" v="Just adding some streetnames"/>
     </changeset>
    </osm>
    EOF
  end

  def multiple_changeset
    changeset=<<-EOF
    <osm version="0.6" generator="OpenStreetMap server">
      <changeset id="10" user="fred" uid="123" created_at="2008-11-08T19:07:39+01:00" open="true" min_lon="7.0191821" min_lat="49.2785426" max_lon="7.0197485" max_lat="49.2793101">
        <tag k="created_by" v="JOSM 1.61"/>
        <tag k="comment" v="Just adding some streetnames"/>
     </changeset>
     <changeset id="11" user="fred" uid="123" created_at="2008-11-08T19:07:39+01:00" open="true" min_lon="7.0191821" min_lat="49.2785426" max_lon="7.0197485" max_lat="49.2793101">
       <tag k="created_by" v="JOSM 1.61"/>
       <tag k="comment" v="Just adding some streetnames"/>
    </changeset>
    </osm>
    EOF
  end

  describe '#find:' do

    def request_url
      "http://www.openstreetmap.org/api/0.6/changeset/10"
    end

    def stubbed_request
      stub_request(:get, request_url)
    end

    it "should build a Change from API response via find_changeset_object" do
      stubbed_request.to_return(:status => 200, :body => single_changeset, :headers => {'Content-Type' => 'application/xml'})
      changeset = osm.find_changeset(10)
      assert_requested :get, request_url, :times => 1
      changeset.class.should eql Changeset
    end

    it "should raise an NotFound error, when a changeset cannot be found" do
      stubbed_request.to_return(:status => 404, :body => '', :headers => {'Content-Type' => 'text/plain'})
      node = osm.find_changeset(10)
      node.should be_nil
    end
  end

  describe '#create' do

    def request_url
      "http://a_username:a_password@www.openstreetmap.org/api/0.6/changeset/create"
    end

    def stub_create_request
      stub_request(:put, request_url)
    end

    it "should post a new changeset with given comment" do
      body = Changeset.new(:tags => { :comment => 'New changeset' }).to_xml

      stub_create_request.with(:body => body).to_return(:status => 200, :body => "3", :headers => {'Content-Type' => 'plain/text'})
      auth_osm.should_receive(:find_changeset).with(3).and_return(cs = double())
      auth_osm.create_changeset('New changeset').should == cs
    end
  end

  describe "#find_or_create_open_changeset" do
    it "returns an exisiting changeset if that exists and is open" do
      auth_osm.should_receive(:find_changeset).with(3).and_return(cs = double(:open? => true))
      auth_osm.should_not_receive(:create_changeset)
      auth_osm.find_or_create_open_changeset(3, "some foo comment").should == cs
    end

    it "returns an new changeset if the requested one exists and is closed" do
      auth_osm.should_receive(:find_changeset).with(3).and_return(double(:open? => false))
      auth_osm.should_receive(:create_changeset).with("some foo comment", {}).and_return(cs = double())
      auth_osm.find_or_create_open_changeset(3, "some foo comment").should == cs
    end

    it "returns an new changeset if the requested one doesn't exist" do
      auth_osm.should_receive(:find_changeset).with(3).and_return(nil)
      auth_osm.should_receive(:create_changeset).with("some foo comment", {}).and_return(cs = double())
      auth_osm.find_or_create_open_changeset(3, "some foo comment").should == cs
    end

    it "appends arbitrary tags to the changeset itself" do
      auth_osm.should_receive(:find_changeset).with(3).and_return(nil)
      auth_osm.should_receive(:create_changeset).with("some foo comment", :source => 'http://example.com' ).and_return(cs = double())
      auth_osm.find_or_create_open_changeset(3, "some foo comment", :source => 'http://example.com' ).should == cs
    end
  end

  describe '#find_for_user' do

    def request_url
      "http://www.openstreetmap.org/api/0.6/changesets?user=1234"
    end

    def stubbed_request
      stub_request(:get, request_url)
    end

    let! :stub_user_lookup do
      stub_request(:get, "http://a_username:a_password@www.openstreetmap.org/api/0.6/user/details").to_return(:status => 200, :body => valid_fake_user, :headers => {'Content-Type' => 'application/xml'} )
    end

    it "should not find changeset for user if user has none" do
      stubbed_request.to_return(:status => 200, :body => missing_changeset, :headers => {'Content-Type' => 'application/xml'})
      changesets = auth_osm.find_changesets_for_user
      changesets.should be_empty
    end

    it "should find a single changeset for user" do
      stubbed_request.to_return(:status => 200, :body => single_changeset, :headers => {'Content-Type' => 'application/xml'})
      changesets = auth_osm.find_changesets_for_user
      changesets.size.should eql 1
      changesets.first.class.should eql Changeset
    end

    it "should find a multiple changesets for a user" do
      stubbed_request.to_return(:status => 200, :body => multiple_changeset, :headers => {'Content-Type' => 'application/xml'})
      changesets = auth_osm.find_changesets_for_user
      changesets.size.should eql 2
      changesets.first.class.should eql Changeset
    end
  end

  describe '#update:' do
  end

  describe '#close' do
  end
end


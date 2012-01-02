require 'webmock/rspec'
require 'osm-client'

describe 'OpenStreetMap' do

  before do
    WebMock.disable_net_connect!
  end

  let :osm do
    OpenStreetMap.new
  end

  describe '::Node' do

    def valid_fake_node
      node=<<-EOF
      <osm>
       <node id="123" lat="51.2" lon="13.4" version="142" changeset="12" user="fred" uid="123" visible="true" timestamp="2005-07-30T14:27:12+01:00">
         <tag k="note" v="Just a node"/>
         <tag k="amenity" v="bar" />
         <tag k="name" v="The rose" />
       </node>
      </osm>
      EOF
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

    describe '#find:' do

      let :request_url do
        "http://www.openstreetmap.org/api/0.6/node/1234"
      end

      let :stubbed_request do
        stub_request(:get, request_url)
      end

      it "should build a Node from API response via get_object" do
        stubbed_request.to_return(:status => 200, :body => valid_fake_node, :headers => {'Content-Type' => 'application/xml'})
        node = osm.find_element('node', 1234)
        assert_requested :get, request_url, :times => 1
        node.class.should eql OpenStreetMap::Node
      end

      it "should build a Node from API response via get_node" do
        stubbed_request.to_return(:status => 200, :body => valid_fake_node, :headers => {'Content-Type' => 'application/xml'})
        node = osm.find_node(1234)
        node.class.should eql OpenStreetMap::Node
      end

      it "should raise an Gone error, when a node has been deleted" do
        stubbed_request.to_return(:status => 410, :body => '', :headers => {'Content-Type' => 'text/plain'})
        lambda {
          node = osm.find_node(1234)
        }.should raise_error(OpenStreetMap::Gone)
      end

      it "should raise an NotFound error, when a node cannot be found" do
        stubbed_request.to_return(:status => 404, :body => '', :headers => {'Content-Type' => 'text/plain'})
        lambda {
          node = osm.find_node(1234)
        }.should raise_error(OpenStreetMap::NotFound)
      end
    end

    describe '#create:' do

      let :osm do
        OpenStreetMap.new(OpenStreetMap::BasicAuthClient.new('a_username', 'a_password'))
      end

      let :node do
        OpenStreetMap::Node.new
      end

      let :request_url do
        "http://a_username:a_password@www.openstreetmap.org/api/0.6/node/create"
      end

      let :stubbed_request do
        stub_request(:put, request_url)
      end

      let! :stub_changeset_lookup do
        stub_request(:get, "http://www.openstreetmap.org/api/0.6/changesets?open=true&user=1234").to_return(:status => 200, :body => valid_fake_changeset, :headers => {'Content-Type' => 'application/xml'} )
      end

      let! :stub_user_lookup do
        stub_request(:get, "http://a_username:a_password@www.openstreetmap.org/api/0.6/user/details").to_return(:status => 200, :body => valid_fake_user, :headers => {'Content-Type' => 'application/xml'} )
      end

      it "should create a new Node from given attributes" do
        stubbed_request.to_return(:status => 200, :body => '123', :headers => {'Content-Type' => 'text/plain'})
        node.id.should be_nil
        new_id = osm.save(node)
      end

      it "should not create a Node with invalid xml but raise BadRequest" do
        stubbed_request.to_return(:status => 400, :body => 'The given node is invalid', :headers => {'Content-Type' => 'text/plain'})
        lambda {
          new_id = osm.save(node)
        }.should raise_error(OpenStreetMap::BadRequest)
      end

      it "should not allow to create a node when a changeset has been closed" do
        stubbed_request.to_return(:status => 409, :body => 'The given node is invalid', :headers => {'Content-Type' => 'text/plain'})
        lambda {
          new_id = osm.save(node)
        }.should raise_error(OpenStreetMap::Conflict)
      end

      it "should not allow to create a node when no authentication client is given" do
        osm = OpenStreetMap.new
        lambda {
          osm.save(node)
        }.should raise_error(OpenStreetMap::CredentialsMissing)
      end

    end

    describe '#update:' do

      let :osm do
        OpenStreetMap.new(OpenStreetMap::BasicAuthClient.new('a_username', 'a_password'))
      end

      let! :stub_changeset_lookup do
        stub_request(:get, "http://www.openstreetmap.org/api/0.6/changesets?open=true&user=1234").to_return(:status => 200, :body => valid_fake_changeset, :headers => {'Content-Type' => 'application/xml'} )
      end

      let! :stub_user_lookup do
        stub_request(:get, "http://a_username:a_password@www.openstreetmap.org/api/0.6/user/details").to_return(:status => 200, :body => valid_fake_user, :headers => {'Content-Type' => 'application/xml'} )
      end

      it "should save a edited node" do
        stub_request(:get,  "http://www.openstreetmap.org/api/0.6/node/123").to_return(:status => 200, :body => valid_fake_node, :headers => {'Content-Type' => 'application/xml'})
        stub_request(:post, "http://a_username:a_password@www.openstreetmap.org/api/0.6/node/123").to_return(:status => 200, :body => '2', :headers => {'Content-Type' => 'text/plain'})
        node = osm.find_element('node', 123)
        node.tags['amenity'] = 'restaurant'
        node.tags['name'] = 'Il Tramonto'
        new_version = osm.save(node)
      end

    end

    describe '#delete:' do
    end
  end
end
require 'spec_helper'
include Rosemary
describe Node do

  before do
    WebMock.disable_net_connect!
  end

  let(:changeset) { Changeset.new(:id => 1) }

  let(:osm) { Api.new }

  def stub_changeset_lookup
    stub_request(:get, "http://www.openstreetmap.org/api/0.6/changesets?open=true&user=1234").to_return(:status => 200, :body => valid_fake_changeset, :headers => {'Content-Type' => 'application/xml'} )
  end

  def stub_node_lookup
    stub_request(:get, "http://www.openstreetmap.org/api/0.6/node/123").to_return(:status => 200, :body => valid_fake_node, :headers => {'Content-Type' => 'application/xml'})
  end

  def valid_fake_node
    node=<<-EOF
    <osm>
     <node id="123" lat="51.2" lon="13.4" version="42" changeset="12" user="fred" uid="123" visible="true" timestamp="2005-07-30T14:27:12+01:00">
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

    def request_url
      "http://www.openstreetmap.org/api/0.6/node/1234"
    end

    def stubbed_request
      stub_request(:get, request_url)
    end

    it "should build a Node from API response via get_object" do
      stubbed_request.to_return(:status => 200, :body => valid_fake_node, :headers => {'Content-Type' => 'application/xml'})
      node = osm.find_node 1234
      assert_requested :get, request_url, :times => 1
      expect(node.class).to eql Node
      expect(node.tags.size).to eql 3
      expect(node.tags['name']).to eql 'The rose'
      expect(node['name']).to eql 'The rose'
      node.add_tags('wheelchair' => 'yes')
      expect(node['wheelchair']).to eql 'yes'
    end

    it "should raise a Unavailable, when api times out" do
      stubbed_request.to_timeout
      expect {
        node = osm.find_node(1234)
      }.to raise_exception(Unavailable)
    end

    it "should raise an Gone error, when a node has been deleted" do
      stubbed_request.to_return(:status => 410, :body => '', :headers => {'Content-Type' => 'text/plain'})
      expect {
        node = osm.find_node(1234)
      }.to raise_exception(Gone)
    end

    it "should raise an NotFound error, when a node cannot be found" do
      stubbed_request.to_return(:status => 404, :body => '', :headers => {'Content-Type' => 'text/plain'})
      node = osm.find_node(1234)
      expect(node).to be_nil
    end
  end

  describe 'with BasicAuthClient' do

    let :osm do
      Api.new(BasicAuthClient.new('a_username', 'a_password'))
    end

    def stub_user_lookup
      stub_request(:get, "http://a_username:a_password@www.openstreetmap.org/api/0.6/user/details").to_return(:status => 200, :body => valid_fake_user, :headers => {'Content-Type' => 'application/xml'} )
    end

    describe '#create:' do

      let (:node) { Node.new }

      let (:expected_body) {
        expected_node = node.dup
        expected_node.changeset = changeset.id
        expected_node.to_xml
      }

      def request_url
        "http://a_username:a_password@www.openstreetmap.org/api/0.6/node/create"
      end

      def stubbed_request
        stub_request(:put, request_url)
      end

      before do
        stub_user_lookup
      end

      it "should create a new Node from given attributes" do
        stubbed_request.with(:body => expected_body).
          to_return(:status => 200, :body => '123', :headers => {'Content-Type' => 'text/plain'})

        new_id = osm.create(node, changeset)
      end

      it "should raise a Unavailable, when api times out" do
        stubbed_request.to_timeout
        expect {
          new_id = osm.create(node, changeset)
        }.to raise_exception(Unavailable)
      end

      it "should not create a Node with invalid xml but raise BadRequest" do
        stubbed_request.to_return(:status => 400, :body => 'The given node is invalid', :headers => {'Content-Type' => 'text/plain'})
        expect {
          new_id = osm.save(node, changeset)
        }.to raise_exception(BadRequest)
      end

      it "should not allow to create a node when a changeset has been closed" do
        stubbed_request.to_return(:status => 409, :body => 'The given node is invalid', :headers => {'Content-Type' => 'text/plain'})
        expect {
          new_id = osm.save(node, changeset)
        }.to raise_exception(Conflict)
      end

      it "should not allow to create a node when no authentication client is given" do
        osm = Api.new
        expect {
          osm.save(node, changeset)
        }.to raise_exception(CredentialsMissing)
      end

      it "should set a changeset" do
        stubbed_request.to_return(:status => 200, :body => '123', :headers => {'Content-Type' => 'text/plain'})
        node.changeset = nil
        osm.save(node, changeset)
        expect(node.changeset).to eql changeset.id
      end
    end

    describe '#update:' do

      let :node do
        osm.find_node 123
      end

      before do
        stub_user_lookup
        stub_node_lookup
      end

      it "should save a edited node" do
        stub_request(:put, "http://a_username:a_password@www.openstreetmap.org/api/0.6/node/123").to_return(:status => 200, :body => '43', :headers => {'Content-Type' => 'text/plain'})
        node.tags['amenity'] = 'restaurant'
        node.tags['name'] = 'Il Tramonto'
        expect(node).to receive(:changeset=)
        new_version = osm.save(node, changeset)
        expect(new_version).to eql 43
      end

      it "should set a changeset" do
        stub_request(:put, "http://a_username:a_password@www.openstreetmap.org/api/0.6/node/123").to_return(:status => 200, :body => '43', :headers => {'Content-Type' => 'text/plain'})
        node.changeset = nil
        osm.save(node, changeset)
        expect(node.changeset).to eql changeset.id
      end


    end

    describe '#delete:' do

      let :node do
        osm.find_node 123
      end

      before do
        stub_changeset_lookup
        stub_user_lookup
        stub_node_lookup
      end

      it "should not delete an node with missing id" do
        node = Node.new
        osm.destroy(node, changeset)
      end

      it "should delete an existing node" do
        stub_request(:delete, "http://a_username:a_password@www.openstreetmap.org/api/0.6/node/123").to_return(:status => 200, :body => '43', :headers => {'Content-Type' => 'text/plain'})
        expect(node).to receive(:changeset=)
        new_version = osm.destroy(node, changeset)
        expect(new_version).to eql 43 # new version number
      end

      it "should raise an error if node to be deleted is still part of a way" do
        stub_request(:delete, "http://a_username:a_password@www.openstreetmap.org/api/0.6/node/123").to_return(:status => 400, :body => 'Version does not match current database version', :headers => {'Content-Type' => 'text/plain'})
        expect {
          response = osm.destroy(node, changeset)
          expect(response).to eql "Version does not match current database version"
        }.to raise_exception BadRequest
      end

      it "should raise an error if node cannot be found" do
        stub_request(:delete, "http://a_username:a_password@www.openstreetmap.org/api/0.6/node/123").to_return(:status => 404, :body => 'Node cannot be found', :headers => {'Content-Type' => 'text/plain'})
        expect {
          response = osm.destroy(node, changeset)
          expect(response).to eql "Node cannot be found"
        }.to raise_exception NotFound
      end

      it "should raise an error if there is a conflict" do
        stub_request(:delete, "http://a_username:a_password@www.openstreetmap.org/api/0.6/node/123").to_return(:status => 409, :body => 'Node has been deleted in this changeset', :headers => {'Content-Type' => 'text/plain'})
        expect {
          response = osm.destroy(node, changeset)
          expect(response).to eql "Node has been deleted in this changeset"
        }.to raise_exception Conflict
      end

      it "should raise an error if the node is already delted" do
        stub_request(:delete, "http://a_username:a_password@www.openstreetmap.org/api/0.6/node/123").to_return(:status => 410, :body => 'Node has been deleted', :headers => {'Content-Type' => 'text/plain'})
        expect {
          response = osm.destroy(node, changeset)
          expect(response).to eql "Node has been deleted"
        }.to raise_exception Gone
      end

      it "should raise an error if the node is part of a way" do
        stub_request(:delete, "http://a_username:a_password@www.openstreetmap.org/api/0.6/node/123").to_return(:status => 412, :body => 'Node 123 is still used by way 456', :headers => {'Content-Type' => 'text/plain'})
        expect {
          response = osm.destroy(node, changeset)
          expect(response).to eql "Node 123 is still used by way 456"
        }.to raise_exception Precondition
      end

      it "should set the changeset an existing node" do
        stub_request(:delete, "http://a_username:a_password@www.openstreetmap.org/api/0.6/node/123").to_return(:status => 200, :body => '43', :headers => {'Content-Type' => 'text/plain'})
        node.changeset = nil
        new_version = osm.destroy(node, changeset)
        expect(node.changeset).to eql changeset.id
      end
    end
  end

  describe 'with OauthClient' do

    let :consumer do
      OAuth::Consumer.new(  'a_key', 'a_secret',
                            {
                              :site => 'http://www.openstreetmap.org',
                              :request_token_path => '/oauth/request_token',
                              :access_token_path => '/oauth/access_token',
                              :authorize_path => '/oauth/authorize'
                            }
                          )
    end

    let :access_token do
      OAuth::AccessToken.new(consumer, 'a_token', 'a_secret')
    end

    let :osm do
      Api.new(OauthClient.new(access_token))
    end

    def stub_user_lookup
      stub_request(:get, "http://www.openstreetmap.org/api/0.6/user/details").to_return(:status => 200, :body => valid_fake_user, :headers => {'Content-Type' => 'application/xml'} )
    end

    describe '#create:' do
      let :node do
        Node.new
      end

      def request_url
        "http://www.openstreetmap.org/api/0.6/node/create"
      end

      def stubbed_request
        stub_request(:put, request_url)
      end

      before do
        stub_changeset_lookup
        stub_user_lookup
      end

      it "should create a new Node from given attributes" do
        stubbed_request.to_return(:status => 200, :body => '123', :headers => {'Content-Type' => 'text/plain'})
        expect(node.id).to be_nil
        new_id = osm.save(node, changeset)
      end

      it "should raise a Unavailable, when api times out" do
        stubbed_request.to_timeout
        expect {
          new_id = osm.save(node, changeset)
        }.to raise_exception(Unavailable)
      end


      it "should not create a Node with invalid xml but raise BadRequest" do
        stubbed_request.to_return(:status => 400, :body => 'The given node is invalid', :headers => {'Content-Type' => 'text/plain'})
        expect {
          new_id = osm.save(node, changeset)
        }.to raise_exception(BadRequest)
      end

      it "should not allow to create a node when a changeset has been closed" do
        stubbed_request.to_return(:status => 409, :body => 'The given node is invalid', :headers => {'Content-Type' => 'text/plain'})
        expect {
          new_id = osm.save(node, changeset)
        }.to raise_exception(Conflict)
      end

      it "should not allow to create a node when no authentication client is given" do
        osm = Api.new
        expect {
          osm.save(node, changeset)
        }.to raise_exception(CredentialsMissing)
      end

    end

    describe '#update:' do

      let :node do
        osm.find_node 123
      end

      before do
        stub_changeset_lookup
        stub_user_lookup
        stub_node_lookup
      end

      it "should save a edited node" do
        stub_request(:put, "http://www.openstreetmap.org/api/0.6/node/123").to_return(:status => 200, :body => '43', :headers => {'Content-Type' => 'text/plain'})
        node.tags['amenity'] = 'restaurant'
        node.tags['name'] = 'Il Tramonto'
        expect(node).to receive(:changeset=)
        new_version = osm.save(node, changeset)
        expect(new_version).to eql 43
      end
    end

    describe '#delete:' do

      let :node do
        osm.find_node 123
      end

      before do
        stub_changeset_lookup
        stub_user_lookup
        stub_node_lookup
      end

      it "should delete an existing node" do
        stub_request(:delete, "http://www.openstreetmap.org/api/0.6/node/123").to_return(:status => 200, :body => '43', :headers => {'Content-Type' => 'text/plain'})
        expect(node).to receive(:changeset=)
        expect {
          # Delete is not implemented using oauth
          new_version = osm.destroy(node, changeset)
        }.to raise_exception(NotImplemented)
      end
    end
  end
end
require 'spec_helper'
include Rosemary
describe Note do

  before do
    WebMock.disable_net_connect!
  end

  let(:osm) { Api.new }

  def valid_fake_note
    note=<<-EOF
    <osm version="0.6" generator="OpenStreetMap server">
    <note lon="102.2205" lat="2.1059">
      <id>174576</id>
      <url>http://www.openstreetmap.org/api/0.6/notes/174576</url>
      <comment_url>http://www.openstreetmap.org/api/0.6/notes/174576/comment</comment_url>
      <close_url>http://www.openstreetmap.org/api/0.6/notes/174576/close</close_url>
      <date_created>2014-05-26 16:00:04 UTC</date_created>
      <status>open</status>
      <comments>
        <comment>
          <date>2014-05-26 16:00:04 UTC</date>
          <uid>2044077</uid>
          <user>osmthis</user>
          <user_url>http://www.openstreetmap.org/user/osmthis</user_url>
          <action>opened</action>
          <text>Test note</text>
          <html>&lt;p&gt;Test note&lt;/p&gt;</html>
        </comment>
      </comments>
    </note>
    </osm>
    EOF
  end

  describe 'with BasicAuthClient' do

    let :osm do
      Api.new(BasicAuthClient.new('a_username', 'a_password'))
    end

    describe '#create_note:' do

      def request_url
        "http://a_username:a_password@www.openstreetmap.org/api/0.6/notes?lat=2.1059&lon=102.2205&text=Test%20note"
      end

      def stubbed_request
        stub_request(:post, request_url)
      end

      def valid_note
        {lon: 102.2205, lat: 2.1059, text: 'Test note'}
      end

      it "should create a new Note from given attributes" do
        stubbed_request.
          to_return(:status => 200, :body => valid_fake_note, :headers => {'Content-Type' => 'application/xml'})

        new_note = osm.create_note(valid_note)
        new_note.id.should eql '174576'
        new_note.lon.should eql '102.2205'
        new_note.lat.should eql '2.1059'
        new_note.text.should eql 'Test note'
        new_note.user.should eql 'osmthis'
        new_note.action.should eql 'opened'
      end
    end

  end
end
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
    <note lon="120.9283065" lat="15.0115916">
      <id>397</id>
      <url>http://api06.dev.openstreetmap.org/api/0.6/notes/397</url>
      <comment_url>http://api06.dev.openstreetmap.org/api/0.6/notes/397/comment</comment_url>
      <close_url>http://api06.dev.openstreetmap.org/api/0.6/notes/397/close</close_url>
      <date_created>2014-04-23 13:57:37 UTC</date_created>
      <status>open</status>
      <comments>
        <comment>
          <date>2014-04-23 13:57:37 UTC</date>
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
        "http://a_username:a_password@www.openstreetmap.org/api/0.6/notes?lat=15.0115916&lon=120.9283065&text=Test%20note"
      end

      def stubbed_request
        stub_request(:post, request_url)
      end

      def valid_note
        {lon: 120.9283065, lat: 15.0115916, text: 'Test note'}
      end

      it "should create a new Note from given attributes" do
        stubbed_request.
          to_return(:status => 200, :body => valid_fake_note, :headers => {'Content-Type' => 'application/xml'})

        new_note = osm.create_note(valid_note)
        new_note.id.should eql '397'
        new_note.lon.should eql '120.9283065'
        new_note.lat.should eql '15.0115916'
        new_note.text.should eql 'Test note'
      end
    end

  end
end
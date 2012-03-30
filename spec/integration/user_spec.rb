require 'spec_helper'

describe Rosemary::User do

  before do
    WebMock.disable_net_connect!
  end

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
    Rosemary::Api.new(Rosemary::OauthClient.new(access_token))
  end

  def valid_fake_user
    way=<<-EOF
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

  describe '#find:' do

    it "should build a User from API response via find_user" do
      stub_request(:get, "http://www.openstreetmap.org/api/0.6/user/details").to_return(:status => 200, :body => valid_fake_user, :headers => {'Content-Type' => 'application/xml'})
      user = osm.find_user
      user.class.should eql Rosemary::User
    end

    it "should raise error from api" do
      stub_request(:get, "http://www.openstreetmap.org/api/0.6/user/details").to_return(:status => 403, :body => "OAuth token doesn't have that capability.", :headers => {'Content-Type' => 'plain/text'})
      lambda {
        osm.find_user
      }.should raise_error Rosemary::Forbidden
    end
  end
end


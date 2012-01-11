# OpenStreetMap for ruby

[![alt text][2]][1]

  [1]: http://travis-ci.org/#!/sozialhelden/openstreetmap
  [2]: https://secure.travis-ci.org/sozialhelden/openstreetmap.png

This is an API client for the current OpenStreetMap API v0.6

It provides easy access to OpenStreetMap (OSM) data. OK, gimme some code:

    require 'rosm'
    api = OpenStreetMap::Api.new
    node = api.find_node(123)
     => #<OpenStreetMap::Node:0x1019268d0 @changeset=7836598, @timestamp=Mon Apr 11 19:40:43 UTC 2011, @user="Turleder'n", @tags={}, @uid=289426, @version=4, @lat=59.9502252, @id=123, @lon=10.7899133>

Modification of data is supported too.

    client = OpenStreetMap::BasicAuthClient('osm_user_nane', 'password')
    api = OpenStreetMap::Api.new(client)
    node = OpenStreetMap::Node.new(:lat => 52.0, :lon => 13.4)
    api.save(node)

Yeah, i can hear you sayin: 'Seriously, do i have to provide username and password? Is that secure?' Providing username and password is prone to some security issues, especially because the OSM API does not provide an SSL service. But wait, there is some more in store for you: OAuth! It's much more secure for the user and your OSM app. But it comes with a price: You have to register an application on http://www.openstreetmap.org. After you have your app registered you get an app key and secret. Keep it in a save place.

    consumer = OAuth::Consumer.new(  'osm_app_key', 'osm_app_secret',
                          { :site => 'http://www.openstreetmap.org',
                            :request_token_path => '/oauth/request_token',
                            :access_token_path => '/oauth/access_token',
                            :authorize_path => '/oauth/authorize'
                          })
    access_token = OAuth::AccessToken(consumer, 'osm_user_token', 'osm_user_key')
    client = OpenStreetMap::OauthClient(access_token)
    api = OpenStreetMap::Api.new(client)
    node = OpenStreetMap::Node.new(:lat => 52.0, :lon => 13.4)
    api.save(node)

Every request to the API which requires authentication, which is mainly write access, is now handled by the OauthClient. Does that sound good?



## Feedback and Contributions

We appreciate your feedback and contributions. If you find a bug, feel free to to open a GitHub issue. Better yet, add a test that exposes the bug, fix it and send us a pull request.
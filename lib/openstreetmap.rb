require 'lib/hash'
require 'lib/callbacks'
require 'lib/open_street_map/tags'
require 'lib/open_street_map/element'
require 'lib/open_street_map/node'
require 'lib/open_street_map/way'
require 'lib/open_street_map/changeset'
require 'lib/open_street_map/relation'
require 'lib/open_street_map/user'
require 'lib/open_street_map/errors'
require 'lib/open_street_map/basic_auth_client'
require 'lib/open_street_map/oauth_client'
require 'lib/open_street_map/api'
require 'oauth'

# The OpenStreetMap class handles all calls to the OpenStreetMap API.
#
# Usage:
#   require 'osm'
#   auth_client = OpenStreetMap::BasicAuthClient.new(:user_name => 'user', :password => 'a_password')
#   osm = OpenStreetMap.new(auth_client)
#   @node = osm.find_node(1234)
#   @node.tags << {:wheelchair => 'no'}
#   osm.save(@node)
#
module OpenStreetMap

end

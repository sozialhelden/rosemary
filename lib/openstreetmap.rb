require 'hash'
require 'active_model'
require 'changeset_callbacks'
require 'open_street_map/tags'
require 'open_street_map/element'
require 'open_street_map/node'
require 'open_street_map/way'
require 'open_street_map/changeset'
require 'open_street_map/relation'
require 'open_street_map/user'
require 'open_street_map/errors'
require 'open_street_map/basic_auth_client'
require 'open_street_map/oauth_client'
require 'osm_parser'
require 'open_street_map/api'
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

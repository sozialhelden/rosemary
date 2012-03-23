require "rosemary/version"

require 'hash'
require 'active_model'
require 'changeset_callbacks'
require 'rosemary/tags'
require 'rosemary/element'
require 'rosemary/node'
require 'rosemary/way'
require 'rosemary/changeset'
require 'rosemary/relation'
require 'rosemary/member'
require 'rosemary/user'
require 'rosemary/errors'
require 'rosemary/basic_auth_client'
require 'rosemary/oauth_client'
require 'rosemary/parser'
require 'rosemary/api'
require 'oauth'

# The Rosemary class handles all calls to the OpenStreetMap API.
#
# Usage:
#   require 'osm'
#   auth_client = Rosemary::BasicAuthClient.new(:user_name => 'user', :password => 'a_password')
#   osm = Rosemary.new(auth_client)
#   @node = osm.find_node(1234)
#   @node.tags << {:wheelchair => 'no'}
#   osm.save(@node)
#
module Rosemary

end

require 'hash'
require 'open_street_map/tags'
require 'open_street_map/osm_object'
require 'open_street_map/node'
require 'open_street_map/changeset'
require 'open_street_map/api'

module OpenStreetMap
  # An object was not found in the database.
  class NotFoundError < StandardError
  end
end
# Contains the OpenStreetMap::API class

require 'httparty'
require 'open_street_map/element'
require 'open_street_map/node'

module OpenStreetMap

  # Unspecified OSM API error.
  class APIError < StandardError; end

  # The API returned more than one OSM object where it should only have returned one.
  class APITooManyObjects < APIError; end

  # The API returned HTTP 400 (Bad Request).
  class APIBadRequest < APIError; end # 400

  # The API operation wasn't authorized. This happens if you didn't set the user and
  # password for a write operation.
  class APIUnauthorized < APIError; end # 401

  # The object was not found (HTTP 404). Generally means that the object doesn't exist
  # and never has.
  class APINotFound < APIError; end # 404

  # The object was not found (HTTP 410), but it used to exist. This generally means
  # that the object existed at some point, but was deleted.
  class APIGone < APIError; end # 410

  # Unspecified API server error.
  class APIServerError < APIError; end # 500

  # The OpenStreetMap::API class handles all calls to the OpenStreetMap API.
  #
  # Usage:
  #   require 'open_street_map/api'
  #
  #   @node = OpenStreetMap::Api.get_object('node', 1234)
  #
  # In most cases you can use the more convenient methods on the OpenStreetMap::Node, OpenStreetMap::Way,
  # or OpenStreetMap::Relation objects.
  #
  class Api
    include HTTParty
    # the default base URI for the API
    base_uri 'http://www.openstreetmap.org/api/0.6/'
    format :xml

    # Get an object ('node', 'way', or 'relation') with specified ID from API.
    #
    # call-seq: get_object(type, id) -> OpenStreetMap::Object
    #
    def self.get_object(type, id)
        raise ArgumentError.new("type needs to be one of 'node', 'way', and 'relation'") unless type =~ /^(node|way|relation)$/
        raise TypeError.new('id needs to be a positive integer') unless(id.kind_of?(Fixnum) && id > 0)
        response = get("/#{type}/#{id}")
        check_response_codes(response)
        OpenStreetMap::Node.new(response['osm']['node'])
    end

    private

    def self.check_response_codes(response)
        case response.code.to_i
            when 200 then return
            when 404 then raise APINotFound
            when 410 then raise APIGone
            when 500 then raise APIServerError
            else raise APIError
        end
    end

  end

end

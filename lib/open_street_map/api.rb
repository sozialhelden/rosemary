# Contains the OpenStreetMap::API class
require 'httparty'

module OpenStreetMap

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

    class << self
      attr_accessor :client
    end

    # Get an object ('node', 'way', or 'relation') with specified ID from API.
    #
    # call-seq: get_object(type, id) -> OpenStreetMap::Element
    #
    def self.get_object(type, id)
      raise ArgumentError.new("type needs to be one of 'node', 'way', and 'relation'") unless type =~ /^(node|way|relation)$/
      raise TypeError.new('id needs to be a positive integer') unless(id.kind_of?(Fixnum) && id > 0)
      response = get("/#{type}/#{id}")
      check_response_codes(response)
      case type
      when 'node'
        OpenStreetMap::Node.new(response['osm']['node'])
      when 'way'
        OpenStreetMap::Way.new(response['osm']['way'])
      when 'relation'
        OpenStreetMap::Relation.new(response['osm']['relation'])
      end
    end

    def self.get_node(id)
      get_object('node', id)
    end

    def self.get_way(id)
      get_object('way', id)
    end

    private

    def self.check_response_codes(response)
      case response.code.to_i
        when 200 then return
        when 400 then raise BadRequest
        when 404 then raise NotFound
        when 410 then raise Gone
        when 500 then raise ServerError
        else raise APIError
      end
    end

  end

end

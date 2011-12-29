require 'lib/hash'
require 'lib/open_street_map/tags'
require 'lib/open_street_map/element'
require 'lib/open_street_map/node'
require 'lib/open_street_map/way'
require 'lib/open_street_map/relation'
require 'lib/open_street_map/errors'
require 'lib/open_street_map/basic_auth_client'
require 'lib/open_street_map/oauth_client'
require 'httparty'

# The OpenStreetMap class handles all calls to the OpenStreetMap API.
#
# Usage:
#   require 'open_street_map/api'
#   osm = OpenStreetMap.new(:user_name => 'user', :password => 'a_password')
#   @node = osm.find(:node => 1234)
#   @node.tags << {:wheelchair => 'no'}
#   osm.save(@node)
#
# In most cases you can use the more convenient methods on the OpenStreetMap::Node, OpenStreetMap::Way,
# or OpenStreetMap::Relation objects.
#
class OpenStreetMap
  include HTTParty
  API_VERSION = "0.6".freeze

  # the default base URI for the API
  base_uri "http://www.openstreetmap.org/api/#{API_VERSION}"

  attr_accessor :client

  def initialize(client=nil)
    @client = client
  end

  # Get an object ('node', 'way', or 'relation') with specified ID from API.
  #
  # call-seq: find_element('node', id) -> OpenStreetMap::Element
  #
  def find_element(type, id)
    raise ArgumentError.new("type needs to be one of 'node', 'way', and 'relation'") unless type =~ /^(node|way|relation)$/
    raise TypeError.new('id needs to be a positive integer') unless(id.kind_of?(Fixnum) && id > 0)
    response = self.class.get("/#{type}/#{id}")
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

  # Get a Node with specified ID from API.
  #
  # call-seq: find_node(id) -> OpenStreetMap::Node
  #
  def find_node(id)
    find_element('node', id)
  end

  # Get a Way with specified ID from API.
  #
  # call-seq: find_way(id) -> OpenStreetMap::Way
  #
  def find_way(id)
    find_element('way', id)
  end

  # Get a Relation with specified ID from API.
  #
  # call-seq: find_relation(id) -> OpenStreetMap::Relation
  #
  def find_relation(id)
    find_element('relation', id)
  end

  def save(element)
    raise CredentialsMissing if @client.nil?
    response = self.class.put("/#{element.type.downcase}/create", :body => element.to_xml )
    check_response_codes(response)
  end

  private

  def check_response_codes(response)
    body = response.body
    case response.code.to_i
      when 200 then return
      when 400 then raise BadRequest.new(body)
      when 401 then raise Unauthorized.new(body)
      when 404 then raise NotFound.new(body)
      when 405 then raise MethodNotAllowed.new(body)
      when 409 then raise Conflict.new(body)
      when 410 then raise Gone.new(body)
      when 412 then raise Precondition.new(body)
      when 500 then raise ServerError
      else raise Error
    end
  end


end

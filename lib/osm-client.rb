require 'lib/hash'
require 'lib/callbacks'
require 'lib/open_street_map/tags'
require 'lib/open_street_map/element'
require 'lib/open_street_map/node'
require 'lib/open_street_map/way'
require 'lib/open_street_map/changeset'
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
  include Callbacks
  API_VERSION = "0.6".freeze

  # the default base URI for the API
  base_uri "http://www.openstreetmap.org/api/#{API_VERSION}"
  default_timeout 2

  attr_accessor :client

  attr_accessor :changeset

  def initialize(client=nil)
    @client = client
  end

  def changeset!
    @changeset ||= create_changeset
  end

  # Get an object ('node', 'way', or 'relation') with specified ID from API.
  #
  # call-seq: find_element('node', id) -> OpenStreetMap::Element
  #
  def find_element(type, id)
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
    when 'changeset'
      OpenStreetMap::Changeset.new(response['osm']['changeset'])
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

  # Get a Changeset with specified ID from API.
  #
  # call-seq: find_changeset(id) -> OpenStreetMap::Changeset
  #
  def find_changeset(id)
    find_element('changeset', id)
  end

  def find_user
    raise CredentialsMissing if client.nil?
    do_authenticated_request(:get, "/user/details")
  end

  # Saves an element to the API.
  # If it has no id yet, the element will be created, otherwise updated.
  def save(element)
    raise CredentialsMissing if client.nil?
    response = if element.id.nil?
      create(element)
    else
      update(element)
    end
    check_response_codes(response)
  end

  def create(element)
    raise CredentialsMissing if client.nil?
    put("/#{element.type.downcase}/create", :body => element.to_xml)
  end

  def update(element)
    raise CredentialsMissing if client.nil?
    raise ChangesetMissing unless changeset.open?
    post("/#{element.type.downcase}/#{element.id}", :body => element.to_xml)
  end

  def create_changeset
    response = case client
    when OpenStreetMap::BasicAuthClient
      self.class.put("/changeset/create", :body => '<osm><changeset><tag k="created_by" v="rOSM v 0.0.1" /></changeset></osm>', :basic_auth => client.credentials )
    when OpenStreetMap::OauthClient
      client.put("/changeset/create", :body => '<osm><changeset><tag k="created_by" v="rOSM v 0.0.1" /></changeset></osm>')
    end
    check_response_codes(response)
    OpenStreetMap::Changeset.new(response['osm']['changeset'])
  end


  private

  def get(url, options = {})
    do_request(:get, url, options)
  end

  def put(url, options = {})
    do_authenticated_request(:put, url, options)
  end

  def post(url, options = {})
    do_authenticated_request(:post, url, options)
  end

  def delete(url, options = {})
    do_authenticated_request(:delete, url, options)
  end

  def do_request(method, url, options)
    self.class.send(method, url, options)
  end

  def do_authenticated_request(method, url, options)
    case client
    when OpenStreetMap::BasicAuthClient
      self.class.send(method, url, options.merge(:basic_auth => client.credentials))
    when OpenStreetMap::OauthClient
      client.send(method, url, options)
    end
  end

  def find_open_changeset
    raise CredentialsMissing if client.nil?
    response = case client
    when OpenStreetMap::BasicAuthClient
      self.class.get("/changesets", :query => {:open => true, :user => client.credentials[:username]})
    when OpenStreetMap::OauthClient
      user = find_user
      client.get("/changesets", :query => {:open => true, :user => user.display_name})
    end
    check_response_codes(response)
    OpenStreetMap::Changeset.new(response['osm']['changeset'])
  end

  def find_or_create_open_changeset(options = {})
    @changeset = find_open_changeset || create_changeset
  end

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

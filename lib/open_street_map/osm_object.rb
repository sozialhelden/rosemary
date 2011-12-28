module OpenStreetMap
  # This is a virtual parent class for the OSM objects Node, Way and Relation.
  class OsmObject

    # To give out unique IDs to the objects we keep a counter that
    # gets decreased every time we use it. See the _next_id method.
    @@id = 0

    # Unique ID
    attr_reader :id

    # The version of this object (as read from file, it
    # is not updated by operations to this object)
    # API 0.6 and above only
    attr_accessor :version

    # The user who last edited this object (as read from file, it
    # is not updated by operations to this object)
    attr_accessor :user

    # The user id of the user who last edited this object (as read from file, it
    # is not updated by operations to this object)
    # API 0.6 and above only
    attr_accessor :uid

    # Last change of this object (as read from file, it is not
    # updated by operations to this object)
    attr_reader :timestamp

    # The changeset the last change of this object was made with.
    attr_reader :changeset

    # Tags for this object
    attr_reader :tags


    # Get OSM::OsmObject from API
    def self.from_api(id, api=OSM::API.new) #:nodoc:
        raise NotImplementedError.new('OsmObject is a virtual base class for the Node, Way, and Relation classes') if self.class == OpenStreetMap::OsmObject
        api.get_object(type, id)
    end

    def initialize(attrs = {}) #:nodoc:
      raise NotImplementedError.new('OsmObject is a virtual base class for the Node, Way, and Relation classes') if self.class == OpenStreetMap::OsmObject
      attrs = {'version' => 1, 'uid' => 1}.merge(attrs.stringify_keys!)
      @id         = attrs['id'].to_i
      @version    = attrs['version'].to_i
      @uid        = attrs['uid'].to_i
      @user       = attrs['user']
      @timestamp  = Time.parse(attrs['timestamp']) rescue nil
      @changeset  = attrs['changeset'].to_i
      @tags       = Tags.new
    end

    # Create an error when somebody tries to set the ID.
    # (We need this here because otherwise method_missing will be called.)
    def id=(id) # :nodoc:
      raise NotImplementedError.new('id can not be changed once the object was created')
    end

    # Set timestamp for this object.
    def timestamp=(timestamp)
      @timestamp = _check_timestamp(timestamp)
    end

    # The list of attributes for this object
    def attribute_list # :nodoc:
      [:id, :version, :uid, :user, :timestamp]
    end

    # Returns a hash of all non-nil attributes of this object.
    #
    # Keys of this hash are <tt>:id</tt>, <tt>:user</tt>,
    # and <tt>:timestamp</tt>. For a Node also <tt>:lon</tt>
    # and <tt>:lat</tt>.
    #
    # call-seq: attributes -> Hash
    #
    def attributes
      attrs = Hash.new
      attribute_list.each do |attribute|
        value = self.send(attribute)
        attrs[attribute] = value unless value.nil?
      end
      attrs
    end

    # Get tag value
    def [](key)
      tags[key]
    end

    # Set tag
    def []=(key, value)
      tags[key] = value
    end

    # Add one or more tags to this object.
    #
    # call-seq: add_tags(Hash) -> OsmObject
    #
    def add_tags(new_tags)
      new_tags.each do |k, v|
        self.tags[k.to_s] = v
      end
      self    # return self so calls can be chained
    end

    # Has this object any tags?
    #
    # call-seq: is_tagged?
    #
    def is_tagged?
      ! @tags.empty?
    end

    # Create a new GeoRuby::Shp4r::ShpRecord with the geometry of
    # this object and the given attributes.
    #
    # This only works if the GeoRuby library is included.
    #
    # geom:: Geometry
    # attributes:: Hash with attributes
    #
    # call-seq: shape(attributes) -> GeoRuby::Shp4r::ShpRecord
    #
    # Example:
    #   require 'rubygems'
    #   require 'geo_ruby'
    #   node = Node(nil, nil, nil, 7.84, 54.34)
    #   g = node.point
    #   node.shape(g, :type => 'Pharmacy', :name => 'Hyde Park Pharmacy')
    #
    def shape(geom, attributes)
      fields = Hash.new
      attributes.each do |key, value|
        fields[key.to_s] = value
      end
      GeoRuby::Shp4r::ShpRecord.new(geom, fields)
    end

    # Get all relations from the API that have his object as members.
    #
    # The optional parameter is an OSM::API object. If none is specified
    # the default OSM API is used.
    #
    # Returns an array of Relation objects or an empty array.
    #
    def get_relations_from_api(api=OSM::API.new)
      api.get_relations_referring_to_object(type, self.id.to_i)
    end

    # Get the history of this object from the API.
    #
    # The optional parameter is an OSM::API object. If none is specified
    # the default OSM API is used.
    #
    # Returns an array of OSM::Node, OSM::Way, or OSM::Relation objects
    # with all the versions.
    def get_history_from_api(api=OSM::API.new)
      api.get_history(type, self.id.to_i)
    end

    # All other methods are mapped so its easy to access tags: For
    # instance obj.name is the same as obj.tags['name']. This works
    # for getting and setting tags.
    #
    #   node = OSM::Node.new
    #   node.add_tags( 'highway' => 'residential', 'name' => 'Main Street' )
    #   node.highway                   #=> 'residential'
    #   node.highway = 'unclassified'  #=> 'unclassified'
    #   node.name                      #=> 'Main Street'
    #
    # In addition methods of the form <tt>key?</tt> are used to
    # check boolean tags. For instance +oneway+ can be 'true' or
    # 'yes' or '1', all meaning the same.
    #
    #   way.oneway?
    #
    # will check this. It returns true if the value of this key is
    # either 'true', 'yes' or '1'.
    def method_missing(method, *args)
      methodname = method.to_s
      if methodname.slice(-1, 1) == '='
        if args.size != 1
          raise ArgumentError.new("wrong number of arguments (#{args.size} for 1)")
        end
        tags[methodname.chop] = args[0]
      elsif methodname.slice(-1, 1) == '?'
        if args.size != 0
          raise ArgumentError.new("wrong number of arguments (#{args.size} for 0)")
        end
        tags[methodname.chop] =~ /^(true|yes|1)$/
      else
        if args.size != 0
          raise ArgumentError.new("wrong number of arguments (#{args.size} for 0)")
        end
        tags[methodname]
      end
    end

    private

    # Return next free ID
    def _next_id
        @@id -= 1
        @@id
    end

    def _check_id(id)
        if id.kind_of?(Integer)
            return id
        elsif id.kind_of?(String)
            raise ArgumentError, "ID must be an integer" unless id =~ /^-?[0-9]+$/
            return id.to_i
        else
            raise ArgumentError, "ID must be integer or string with integer"
        end
    end

    def _check_timestamp(timestamp)
        if timestamp !~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(Z|([+-][0-9]{2}:[0-9]{2}))$/
            raise ArgumentError, "Timestamp is in wrong format (must be 'yyyy-mm-ddThh:mm:ss(Z|[+-]mm:ss)')"
        end
        timestamp
    end

    def _check_lon(lon)
        if lon.kind_of?(Numeric)
            return lon.to_s
        elsif lon.kind_of?(String)
            return lon
        else
            raise ArgumentError, "'lon' must be number or string containing number"
        end
    end

    def _check_lat(lat)
        if lat.kind_of?(Numeric)
            return lat.to_s
        elsif lat.kind_of?(String)
            return lat
        else
            raise ArgumentError, "'lat' must be number or string containing number"
        end
    end

  end
end
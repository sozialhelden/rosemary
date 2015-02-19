require 'httparty'
require 'xml/libxml'

# The XML parser capable of understanding the custom OSM XML format.
class Rosemary::Parser < HTTParty::Parser
  include LibXML::XML::SaxParser::Callbacks

  attr_accessor :context, :description, :lang, :collection

  def parse
    return nil if body.nil? || body.empty?
    if supports_format?
      self.send(format) # This is a hack, cause the xml format would not be recognized ways, but for nodes and relations
    else
      body
    end
  end

  def xml
    # instead of using
    # LibXML::XML::default_substitute_entities = true
    # we change the options of the xml context:
    ctx = XML::Parser::Context.string(body)
    ctx.options = XML::Parser::Options::NOENT
    @parser = LibXML::XML::SaxParser.new(ctx)

    @parser.callbacks = self
    @parser.parse

    if @bounding_box
      @bounding_box
    else
      @collection.empty? ? @context : @collection
    end
  end

  def plain
    body
  end

  def on_start_document   # :nodoc:
    @collection = []
    start_document if respond_to?(:start_document)
  end

  def on_end_document     # :nodoc:
    end_document if respond_to?(:end_document)
  end

  def on_start_element(name, attr_hash)   # :nodoc:
    case @context.class.name
    when 'Rosemary::User'
      case name
      when 'description'  then @description = true
      when 'lang'         then @lang        = true
      end
    when 'Rosemary::Note'
      case name
      when 'id'           then @id          = true
      when 'text'         then @text        = true
      when 'user'         then @user        = true
      when 'action'       then @action      = true
      end
    else
      case name
      when 'node'         then _start_node(attr_hash)
      when 'way'          then _start_way(attr_hash)
      when 'relation'     then _start_relation(attr_hash)
      when 'changeset'    then _start_changeset(attr_hash)
      when 'user'         then _start_user(attr_hash)
      when 'tag'          then _tag(attr_hash)
      when 'nd'           then _nd(attr_hash)
      when 'member'       then _member(attr_hash)
      when 'home'         then _home(attr_hash)
      when 'permissions'  then _start_permissions(attr_hash)
      when 'permission'   then _start_permission(attr_hash)
      when 'note'         then _start_note(attr_hash)
      when 'bounds'       then _start_bounds(attr_hash)
      end
    end
  end

  def on_end_element(name)   # :nodoc:
    case name
    when 'description'  then @description = false
    when 'lang'         then @lang        = false
    when 'id'           then @id          = false
    when 'text'         then @text        = false
    when 'action'       then @action      = false
    when 'user'         then @user        = false
    when 'changeset'    then _end_changeset
    end
  end

  def on_characters(chars)
    case @context.class.name
    when 'Rosemary::User'
      @context.description = chars if @description
      @context.languages << chars if @lang
    when 'Rosemary::Note'
      @context.id = chars if @id
      @context.text << chars if @text
      @context.user = chars if @user
      @context.action = chars if @action
    end
  end

  private
  def _start_node(attr_hash)
    node = Rosemary::Node.new(attr_hash)
    @bounding_box.nodes << node if @bounding_box
    @context = node
  end

  def _start_way(attr_hash)
    way = Rosemary::Way.new(attr_hash)
    @bounding_box.ways << way if @bounding_box
    @context = way
  end

  def _start_relation(attr_hash)
    relation = Rosemary::Relation.new(attr_hash)
    @bounding_box.relations << relation if @bounding_box
    @context = relation
  end

  def _start_changeset(attr_hash)
    @context = Rosemary::Changeset.new(attr_hash)
  end

  def _start_note(attr_hash)
    @context = Rosemary::Note.new(attr_hash)
  end

  def _start_permissions(_)
    # just a few sanity checks: we can only parse permissions as a top level elem
    raise ParseError, "Unexpected <permissions> element" unless @context.nil?
    @context = Rosemary::Permissions.new
  end

  def _start_permission(attr_hash)
    @context << attr_hash['name']
  end

  def _end_changeset
    @collection << @context
  end

  def _start_user(attr_hash)
    @context = Rosemary::User.new(attr_hash)
  end

  def _nd(attr_hash)
    @context << attr_hash['ref']
  end

  def _tag(attr_hash)
    if respond_to?(:tag)
      return unless tag(@context, attr_hash['k'], attr_value['v'])
    end
    @context.tags.merge!(attr_hash['k'] => attr_hash['v'])
  end

  def _member(attr_hash)
    new_member = Rosemary::Member.new(attr_hash['type'], attr_hash['ref'], attr_hash['role'])
    if respond_to?(:member)
      return unless member(@context, new_member)
    end
    @context.members << new_member
  end

  def _home(attr_hash)
    @context.lat = attr_hash['lat']   if attr_hash['lat']
    @context.lon = attr_hash['lon']   if attr_hash['lon']
    @context.lon = attr_hash['zoom']  if attr_hash['zoom']
  end

  def _start_bounds(attr_hash)
    @bounding_box = Rosemary::BoundingBox.new(attr_hash)
  end

end

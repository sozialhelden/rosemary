module Rosemary
  # A collection of OSM tags which can be attached to a Node, Way,
  # or Relation.
  # It is a subclass of Hash.
  class Tags < Hash

    # Return XML for these tags. This method uses the Builder library.
    # The only parameter ist the builder object.
    def to_xml(options = {})
      xml = options[:builder] ||= Builder::XmlMarkup.new
      xml.instruct! unless options[:skip_instruct]
      each do |key, value|
        xml.tag(:k => key, :v => value) unless value.blank?
      end unless empty?
    end

    def []=(key, value)
      # Ignore empty values, cause we don't want them in the OSM anyways
      return if value.blank?
      super(key, value.strip)
    end

    # Return string with comma separated key=value pairs.
    #
    # @return [String] string representation
    #
    def to_s
      sort.collect{ |k, v| "#{k}=#{v}" }.join(', ')
    end

  end
end
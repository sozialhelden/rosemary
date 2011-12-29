class OpenStreetMap
  # A collection of OSM tags which can be attached to a Node, Way,
  # or Relation.
  # It is a subclass of Hash.
  class Tags < Hash

    # Return XML for these tags. This method uses the Builder library.
    # The only parameter ist the builder object.
    def to_xml(xml)
      each do |key, value|
        xml.tag(:k => key, :v => value)
      end
    end

    # Return string with comma separated key=value pairs.
    #
    # call-seq: to_s -> String
    #
    def to_s
      sort.collect{ |k, v| "#{k}=#{v}" }.join(', ')
    end

  end
end
module Ym4r
  module MapstractionPlugin
    #A graphical marker positionned through geographic coordinates (in the WGS84 datum). An HTML info window can be set to be displayed when the marker is clicked on.
    class Marker
      include MappingObject
      attr_accessor :point, :options
      
      def initialize(point, options = {})
        if point.is_a?(Array)
          @point = LatLonPoint.new(point)
        else
          @point = point
        end
        @options = options
      end
      
      def create
        creation = "new Marker(#{MappingObject.javascriptify_variable(@point)})"
        if !@options.empty?
          creation = "addDataToMarker(#{creation},#{MappingObject.javascriptify_variable(@options)})"
        end
        creation
      end
    end

    #A basic Latitude/longitude point.
    class LatLonPoint 
      include MappingObject
      attr_accessor :lat,:lon
      
      def initialize(latlon)
        @lat = latlon[0]
        @lon = latlon[1]
      end
      def create
        "new LatLonPoint(#{@lat},#{@lon})"
      end
    end
    
    #A rectangular bounding box, defined by its south-western and north-eastern corners.
    class BoundingBox < Struct.new(:sw,:ne)
      include MappingObject
      def create
        if sw.is_a?(Array)
          swlat = sw[0]
          swlon = sw[1]
        else #LatLonPoint
          swlat = sw.lat
          swlon = sw.lon
        end
        if(ne.is_a?(Array))
          nelat = ne[0]
          nelon = ne[1]
        else #LatLonPoint
          nelat = ne.lat
          nelon = ne.lon
        end
        "new BoundingBox(#{swlat},#{swlon},#{nelat},#{nelon})"
      end
    end
  end
end

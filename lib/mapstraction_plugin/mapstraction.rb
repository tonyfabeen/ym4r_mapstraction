module Ym4r
  module MapstractionPlugin 

    #Map types of the map
    class MapType
      ROAD = Variable.new("Mapstraction.ROAD")
      SATELLITE = Variable.new("Mapstraction.SATELLITE")
      HYBRID = Variable.new("Mapstraction.HYBRID")
    end

    #Represents a Mapstracted map.
    class Mapstraction
      include MappingObject
                  
      #The id of the DIV that will contain the map in the HTML page. 
      attr_reader :container, :map_type
      
      #A constant containing the declaration of the VML namespace, necessary to display polylines in google maps under IE.
      VML_NAMESPACE = "xmlns:v=\"urn:schemas-microsoft-com:vml\""

      #By default the map in the HTML page will be globally accessible with the name +map+. +map_type+ is one of three choices: <tt>:google</tt>, <tt>:yahoo</tt> or <tt>microsoft</tt>.
      def initialize(container, map_type, variable = "map")
        @container = container
        @map_type = map_type
        @variable = variable
        @init = []
        @init_begin = []
        @init_end = []
        @global_init = []
      end
      
      def self.header(types,options = {})
        a = ""
        Array(types).each do |type|
          if type == :google
            options[:with_vml] = true unless options.has_key?(:with_vml)
            if options.has_key?(:key)
              api_key = options[:key]
            elsif GMAPS_API_KEY.is_a?(Hash)
              #For this environment, multiple hosts are possible.
              #:host must have been passed as option
              if options.has_key?(:host)
                api_key = GMAPS_API_KEY[options[:host]]
              else
                raise AmbiguousGMapsAPIKeyException.new(GMAPS_API_KEY.keys.join(","))
              end
            else
              #Only one possible key: take it
              api_key = GMAPS_API_KEY
            end
            a << "<script src=\"http://maps.google.com/maps?file=api&v=2&key=#{api_key}\" type=\"text/javascript\"></script>\n"
            a << "<style type=\"text/css\">\n v\:* { behavior:url(#default#VML);}\n</style>" if options[:with_vml]
          elsif type == :yahoo
            a << "<script type=\"text/javascript\" src=\"http://api.maps.yahoo.com/ajaxymap?v=3.0&appid=YellowMasp4R\"></script>\n"
          elsif type == :microsoft
            a << "<script src=\"http://dev.virtualearth.net/mapcontrol/v3/mapcontrol.js\"></script>\n"
          end
        end
        a << "<script src=\"/javascripts/mapstraction.js\" type=\"text/javascript\"></script>\n"
        a << "<script src=\"/javascripts/ym4r-mapstraction.js\" type=\"text/javascript\"></script>\n"
        a
      end
     
      #Outputs the <div id=...></div> which has been configured to contain the map. You can pass <tt>:width</tt> and <tt>:height</tt> as options to output this in the style attribute of the DIV element (you could also achieve the same effect by putting the dimension info into a CSS or using the instance method Mapstraction#header_width_height)
      def div(options = {})
        attributes = "id=\"#{@container}\" "
        if options.has_key?(:height) && options.has_key?(:width)
          attributes += "style=\"width:#{options[:width]};height:#{options[:height]}\""
        end
        "<div #{attributes}></div>"
      end

      #Outputs a style declaration setting the dimensions of the DIV container of the map. This info can also be set manually in a CSS.
      def header_width_height(width,height)
        "<style type=\"text/css\">\n##{@container} { height: #{height}px;\n  width: #{width}px;\n}\n</style>"
      end

      #Records arbitrary JavaScript code and outputs it during initialization inside the +load+ function.
      def record_init(code)
        @init << code
      end

      #Initializes the controls: you can pass a hash with key <tt>:small</tt> (only one for now) and a boolean value as the value (usually true, since the control is not displayed by default)
      def control_init(controls = {})
        @init << add_small_controls() if controls[:small]
      end

      #Initializes the initial center and zoom of the map. +center+ can be both a GLatLng object or a 2-float array.
      def center_zoom_init(center, zoom)
        if center.is_a?(LatLonPoint)
          @init_begin << set_center_and_zoom(center,zoom)
        else
          @init_begin << set_center_and_zoom(LatLonPoint.new(center),zoom)
        end
      end

      #Initializes the map by adding a marker
      def marker_init(marker)
        @init << add_marker(marker)
      end

      def marker_group_init(marker_group)
        @init << add_marker_group(marker_group)
      end

      #Sets the map type displayed by default after the map is loaded.
      def set_map_type_init(map_type)
        @init << set_map_type(map_type)
      end

      #Locally declare a MappingObject with variable name "name"
      def declare_init(variable, name)
        @init << variable.declare(name)
      end

      #Records arbitrary JavaScript code and outputs it during initialization outside the +load+ function (ie globally).
      def record_global_init(code)
        @global_init << code
      end
            
      #Declares the marker globally with name +name+
      def marker_global_init(marker,name)
        declare_global_init(marker,name)
        marker_init(marker)
      end

      #Declares the marker group globally with name +name+
      def marker_group_global_init(marker_group,name)
        declare_global_init(marker_group,name)
        marker_group_init(marker_group)
      end

      #Globally declare a MappingObject with variable name "name"
      def declare_global_init(variable,name)
        @global_init << variable.declare(name)
      end
      
      #Outputs the initialization code for the map. By default, it outputs the script tags, performs the initialization in response to the onload event of the window and makes the map globally available.
      def to_html(options = {})
        no_load = options[:no_load]
        no_script_tag = options[:no_script_tag]
        no_declare = options[:no_declare]
        no_global = options[:no_global]
        
        html = ""
        html << "<script type=\"text/javascript\">\n" if !no_script_tag
        #put the functions in a separate javascript file to be included in the page
        html << @global_init * "\n"
        html << "var #{@variable};\n" if !no_declare and !no_global
        html << "window.onload = addCodeToFunction(window.onload,function() {\n" if !no_load
        if !no_declare and no_global 
          html << "#{declare(@variable)}\n"
        else
          html << "#{assign_to(@variable)}\n"
        end
        html << @init_begin * "\n"
        html << @init * "\n"
        html << @init_end * "\n"
        html << "\n});\n" if !no_load
        html << "</script>" if !no_script_tag
        html
      end
      
      #Outputs in JavaScript the creation of a Mapstraction object 
      def create
        "new Mapstraction(\"#{@container}\",\"#{@map_type.to_s}\")"
      end
    end

    class AmbiguousGMapsAPIKeyException < StandardError
    end

  end
end


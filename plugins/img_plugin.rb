FB_HELPERS = File.open("#{File.dirname(__FILE__)}/img_helper.rb").read

create_file "app/helpers/img_helpers.rb", "#{fetch_app_name("/app")}.helpers do\n#{FB_HELPERS}\nend"

require_dependencies 'rmagick'

# img_create(options) ***********************************************
  # => Shortcut for creating an image from a path or creating a blank canvas
    # Params:
    # +options+:: Hash that contains available options for an Magick::Image Object. See img_create_blank for more available options.
    # +options[:path]+:: String for the path to the image file on the server.

# img_from_path(path) ***********************************************
  # => Create a Magick::Image from an image file on the server.
    # Params:
    # +path+:: String for the path to the image file on the server.

# img_create_blank(options) ***********************************************
  # => Create a blank canvas and return set it's properties for an Magick::Image Object
    # Params:
    # +options+:: Hash that contains available options for an Magick::Image Object
    # +options[:width]+:: Integer for the width of the image currently only used if the image is being created from a blank canvas.
    # +options[:height]+:: Integer for the height of the image currently only used if the image is being created from a blank canvas.
    # +options[:background_color]+:: The background color for the empty canvas
    # +options[:quality]+:: Image Quality used when saved to determine the level of compression

# img_resize_crop(img,options) ***********************************************
  # => Will resize to the desired dimensions and maintain ascpect ratio then crop to the width/height based on the GravityType.
    # Params:
    # +img+:: String or Magick::Image Obj.
    # +options+:: Hash that contains available options for an RMagick Object
    # +options[:gravity]+:: GravityType value. Defaults to Magick::CenterGravity . See http://www.imagemagick.org/RMagick/doc/constants.html#GravityType
    # +options[:width]+:: Integer for the width of the image
    # +options[:height]+:: Integer for the height of the image

# img_resize_scale(img,options) ***********************************************
  # => Will resize to the desired dimensions and maintain ascpect ratio
    # Params:
    # +img+:: String or Magick::Image Obj.
    # +options+:: Hash that contains available options for an RMagick Object
    # +options[:width]+:: Integer for the width
    # +options[:height]+:: Integer for the height

# img_grayscale(img[,colors=256]) ***********************************************
  # => convert image to grayscale
    # Params:
    # +img+:: Magick::Image Obj.
    # +colors+:: Integer for the number of colors to use in the conversion default is 256

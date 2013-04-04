
  def img_create(options)
    if options[:path]
      img_create_from_path(options[:path])
    elsif options[:width] && options[:height]
      img_create_blank_image(options)
    else
      nil
    end
  end

  def img_create_from_path(path)
    Magick::ImageList.new(path)
  end

  def img_create_blank(options)
    Magick::Image.new(options[:width],options[:height]) { |i|
      options.keys.each do |key|
        case key
          # I think I would like to make this more dynamic removing the need for a case statement
          #something like i.key where key is the variable attribute that we are trying to set.
          when :background_color
            i.background_color = options[key]
          when :quality
            i.quality = options[key]
          else
        end
      end
    }
  end

  def img_resize_crop(img,options)
    if img.respond_to?('crop_resized')
      gravity = options[:gravity] ? options[:gravity] : Magick::CenterGravity

      if options[:width] && options[:height]
        img.crop_resized! options[:width], options[:height], gravity
      end

    elsif img.is_a? String
      img = img_create :path => img
      img_resize_crop(img,options)
    else
      nil
    end
  end

  def img_resize_scale(img,options)
    if img.respond_to?('resize_to_fit')
      if options[:width] && options[:height]
        img.resize_to_fit! options[:width], options[:height]
      end
    else
      img = img_create :path => img
      img_resize_scale(img,options)
    end
  end

  def img_grayscale(img,colors=256)
    img.quantize colors, Magick::GRAYColorspace
  end
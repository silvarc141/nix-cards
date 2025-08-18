require 'squib'
require 'mini_magick'

# Get crop point that should be passed to squib's crop_x/crop_y to center an image.
# In squib's style, arguments can be regular values or arrays.
def get_centering_crop_point(crop_width, crop_height, image_paths, placeholder_path)

  # treat non-arrays as arrays
  crop_width = Array(crop_width)
  crop_height = Array(crop_height)
  image_paths = Array(image_paths)

  max_length = [crop_width.length, crop_height.length, image_paths.length].max

  image_width = Array.new(max_length)
  image_height = Array.new(max_length)

  # use % to handle single element arrays properly
  max_length.times do |index|
    path = image_paths[index % image_paths.length]
    image = MiniMagick::Image.open(File.exist?(path) ? path : placeholder_path)
    image_width[index] = image.width
    image_height[index] = image.height
  end
  
  image_size = {width: image_width, height: image_height}

  get_centering_crop_point_with_size(crop_width, crop_height, image_size)
end

def get_centering_crop_point_with_size(crop_width, crop_height, image_size)
  crop_width = Array(crop_width)
  crop_height = Array(crop_height)
  image_width = Array(image_size[:width])
  image_height = Array(image_size[:height])
  
  max_length = [crop_width.length, crop_height.length, image_size.length].max
  
  centering_crop_point_x = Array.new(max_length)
  centering_crop_point_y = Array.new(max_length)
  
  max_length.times do |index|
    unpacked_image_width = image_width[index % image_width.length]
    unpacked_image_height = image_height[index % image_height.length]

    centering_crop_point_x[index] = (unpacked_image_width - crop_width[index % crop_width.length]) / 2
    centering_crop_point_y[index] = (unpacked_image_width - crop_height[index % crop_height.length]) / 2
  end
  
  {x: centering_crop_point_x, y: centering_crop_point_y}
end

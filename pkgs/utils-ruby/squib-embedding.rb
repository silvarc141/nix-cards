# frozen_string_literal: true

require 'nokogiri'
require 'game_icons'
require 'mini_magick'
require 'tempfile'

class IconEmbedder
  def initialize(icons_directory, delimiter_start: '[', delimiter_end: ']')
    @icons_directory = icons_directory
    @delimiter_start = delimiter_start
    @delimiter_end = delimiter_end
    @svg_data_cache = {}
    @png_path_cache = {}
    @temp_files = []
  end

  # Inserts zero width character at the start of each line to work around the following squib issue:
  # If only icons are in a line it's height is treated as zero (relevant for text centering and such).
  def fix_line_height(text_string_or_array)
    ZERO_WIDTH_SPACE = "\u200b"

    def inject_zero_width(str)
      return str if str.nil?
      str.to_s.gsub(/^/, ZERO_WIDTH_SPACE)
    end

    if text_string_or_array.is_a?(Array)
      text_string_or_array.map { |str| inject_zero_width(str) }
    else
      inject_zero_width(text_string_or_array)
    end
  end

  def run(embed, text_string_or_array, font_size: 8, scale: 1, prerender: false, dry_run: false)
    keys_in_use = Array(text_string_or_array).join.scan(/#{Regexp.escape(@delimiter_start)}[a-zA-Z0-9_-]+#{Regexp.escape(@delimiter_end)}/).uniq
    return if keys_in_use.empty?

    transform = get_icon_transform(font_size: font_size, scale: scale)

    if prerender
      pixel_dims = {
        width: (300 * transform[:width_c]).round.clamp(1, nil), # Ensure at least 1px
        height: (300 * transform[:height_c]).round.clamp(1, nil) # Ensure at least 1px
      }
      run_png(embed, keys_in_use, transform, pixel_dims, dry_run)
    else
      run_svg(embed, keys_in_use, transform, dry_run)
    end
  end

  def cleanup_temp_files
    return if @temp_files.empty?
    puts "Cleaning up #{@temp_files.count} temporary icon files..."
    @temp_files.each do |file|
      file.close
      file.unlink
    end
    @temp_files.clear
    @png_path_cache.clear
    puts "Cleanup complete."
  end

  def get_svg_data(icon_name)
    @svg_data_cache ||= {}
    @svg_data_cache[icon_name] ||= begin
      file_path = File.join(@icons_directory, "#{icon_name}.svg")
      if File.exist?(file_path)
        File.read(file_path)
      else
        GameIcons.get(icon_name).string
      end
    rescue => e
      warn "Warning: Could not GET SVG data for '#{icon_name}': #{e.message}. Using placeholder."
      '<svg width="1" height="1" xmlns="http://www.w3.org/2000/svg"></svg>'
    end
  end

  # after trial and error this works, TODO: why magic numbers?
  def get_icon_transform(font_size:, scale: 1)
    ratio = 0.1 * scale # why magic number?
    size_in_cells = font_size * ratio
    {
      width_c: size_in_cells,
      height_c: size_in_cells,
      width: "#{size_in_cells}c",
      height: "#{size_in_cells}c",
      dy: "-#{size_in_cells * (1 - ratio * 1.5)}c" # why magic number?
    }
  end

  private

  def run_svg(embed, keys, transform, dry_run)
    keys.each do |key|
      icon_name = key.delete(@delimiter_start).delete(@delimiter_end).to_sym
      svg_data = get_svg_data(icon_name)

      next if svg_data.nil? || svg_data.strip.empty?

      svg_data_for_embed = if dry_run
        doc = Nokogiri::XML(svg_data)
        doc.root['visibility'] = 'hidden'
        doc.to_xml
      else
        svg_data
      end
      
      embed.svg(key: key, data: svg_data_for_embed, **transform.slice(:width, :height, :dy))
    end
  end

  def run_png(embed, keys, transform, pixel_dims, dry_run)
    keys.each do |key|
      real_png_path = get_prerendered_png_path(key, pixel_dims)
      next unless real_png_path

      if dry_run
        invisible_svg = '<svg width="1" height="1" visibility="hidden"></svg>'
        embed.svg(key: key, data: invisible_svg, **transform.slice(:width, :height, :dy))
      else
        embed.png(key: key, file: real_png_path, **transform.slice(:width, :height, :dy))
      end
    end
  end

  def get_prerendered_png_path(key, pixel_dims)
    cache_key = "#{key}_#{pixel_dims[:width]}x#{pixel_dims[:height]}"
    @png_path_cache[cache_key] ||= begin
      icon_name = key.delete(@delimiter_start).delete(@delimiter_end).to_sym
      svg_data = get_svg_data(icon_name)

      return nil if svg_data.nil? || svg_data.strip.empty?

      temp_file = Tempfile.new([icon_name.to_s, '.png'])
      @temp_files << temp_file
      
      image = MiniMagick::Image.read(svg_data)
      image.format "png"
      image.background "none"
      image.resize "#{pixel_dims[:width]}x#{pixel_dims[:height]}"
      image.write temp_file.path
      
      temp_file.path
    rescue => e
      warn "Warning: Could not render icon '#{icon_name}' (key '#{key}') with MiniMagick: #{e.message}"
      nil
    end
  end
end

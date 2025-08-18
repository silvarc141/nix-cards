require 'squib'

def create_simple_background_generator(
  top_level_padding: 0, 
  x: cell(15),
  width: cell(13),
  stroke_width: 3,
  radius: 0,
  fill_color: '#fffff2dd',
  stroke_color: '(375,832.5,250)(420,832.5,325) #3C0606@0.0 #A02424@0.2 #760505@0.4 #8A0303@0.6 #DD5757@0.8 #080808@1.0'
)
  ->(data) {
    y = data.first[:y].map{|prev| prev - top_level_padding}
    height = y.zip(data.last[:y], data.last[:height]).map{|arr|(arr[0] - arr[1]).abs() + arr[2] + top_level_padding}
    rect y: y, x: x, height: height, width: width, stroke_width: stroke_width, fill_color: fill_color, stroke_color: stroke_color, radius: radius
  }
end

# Returns an array of Hashes, each Hash corresponding to a stack entry. Hashes contain calculated y position array (:y) and height array (:height) for card specific data.
#
# Each element in the 'stack' array should be a Hash with the following keys:
# func:
#   closure that takes an array of summed heights and optionally returns a result of squib text
#   dry_run: a boolean parameter that if true should prevent rendering visible elements
#   signature: ->(y, dry_run){ text(y: y, color: dry_run ? '#0000' : '#000F', ... ) }
# offset: offset added to stack for the current element
# padding: offset added to stack for the current and next element, overrides default_padding
# height_override: if specified, used instead of func's result, useful for non-text
def draw_vertical_stack(
  stack:, # array of Hashes
  nrows:, # number of cards for initial array
  global_offset: 0, # offset of the top level container
  default_padding: 0, # default padding for stack entries; if an entry specifies it's own padding, this is ignored
  dry_run: false, # do not render anything
  deck_height: nil, # if specified, entries are stacked from the bottom
  background_func: nil # called after size is calculated but before visible render, signature: ->(y, height){}
)
  from_bottom = deck_height != nil
  get_new_data_entry = ->(){{y: Array.new(nrows, global_offset + (from_bottom ? deck_height : 0)), height: Array.new(nrows, 0)}}
  dummy_heights = Array.new(nrows, 0)

  stack_data = Array.new(stack.length) { get_new_data_entry.call() }

  (from_bottom ? stack.reverse : stack).each_with_index {|current_entry, current_entry_index| 
    offset = current_entry[:offset] || 0
    padding = current_entry[:padding] || default_padding

    previous_entry_data = current_entry_index == 0 ? 
      get_new_data_entry.call() :
      stack_data[current_entry_index - 1]

    stack_data[current_entry_index][:height].map!.with_index{|prev, index|
      if current_entry[:height_override]
        next current_entry[:height_override]
      end

      dry_run_result = current_entry[:func].call(dummy_heights, true)

      if dry_run_result[index][:width] == 0
        next 0
      end

      dry_run_result[index][:height]
    }

    stack_data[current_entry_index][:y] = previous_entry_data[:y].map.with_index{|y, card_index| 
      # set entries with 0 height to y of the previous entry
      if stack_data[current_entry_index][:height][card_index] == 0
        previous_data = stack_data[current_entry_index - 1]
        if from_bottom
          next previous_data[:y][card_index] || offset
        else
          next (previous_data[:y][card_index] + previous_data[:height][card_index]) || offset
        end
      end

      result = y + offset
      if from_bottom
        result -= stack_data[current_entry_index][:height][card_index]
        if (current_entry_index != 0)
          result -= padding
        end
      else
        result += previous_entry_data[:height][card_index]
        if (current_entry_index != 0)
          result += padding
        end
      end

      result
    }
  }

  stack_data = from_bottom ? stack_data.reverse : stack_data

  if background_func
    background_func.call(stack_data)
  end

  if !dry_run
    stack.each_with_index {|current_entry, current_entry_index|
      current_entry[:func].call(stack_data[current_entry_index][:y], false)
    }
  end

  return stack_data
end

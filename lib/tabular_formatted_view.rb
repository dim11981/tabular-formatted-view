# encoding: utf-8

require 'kernel32lib/consoles'
require(File.expand_path('../../lib/view_proxy',__FILE__))
require(File.expand_path('../../lib/formatting',__FILE__))
require(File.expand_path('../../lib/version',__FILE__))

# Viewing module
# formatted output
module Viewing

  # TabularFormattedView class
  # printing and painting stored data
  class TabularFormattedView

    # constants
    # options (color styles)
    DEFAULT_OPTIONS = {
        header_color_style: Kernel32Lib::FOREGROUND_GREEN | Kernel32Lib::FOREGROUND_RED | Kernel32Lib::FOREGROUND_INTENSITY | Kernel32Lib::BACKGROUND_BLUE,
        data_color_style: Kernel32Lib::FOREGROUND_GREEN | Kernel32Lib::FOREGROUND_BLUE | Kernel32Lib::FOREGROUND_INTENSITY | Kernel32Lib::BACKGROUND_BLUE,
        border_color_style: Kernel32Lib::FOREGROUND_GREEN | Kernel32Lib::FOREGROUND_BLUE | Kernel32Lib::FOREGROUND_INTENSITY | Kernel32Lib::BACKGROUND_BLUE,
        title_color_style: Kernel32Lib::FOREGROUND_BLUE | Kernel32Lib::FOREGROUND_RED | Kernel32Lib::BACKGROUND_WHITE | Kernel32Lib::BACKGROUND_INTENSITY
    }

    # unicode symbols for padding and delimiters
    DEFAULT_SYMBOLS = {
        light_shade: "\u2591",
        box_drawings_light_horizontal: "\u2500",
        box_drawings_light_vertical: "\u2502",
        box_drawings_light_vertical_and_right: "\u251c",
        box_drawings_light_vertical_and_left: "\u2524",
        box_drawings_light_vertical_and_horizontal: "\u253c",
        box_drawings_double_horizontal: "\u2550",
        box_drawings_down_single_and_right_double: "\u2552",
        box_drawings_down_single_and_left_double: "\u2555",
        box_drawings_up_single_and_right_double: "\u2558",
        box_drawings_up_single_and_left_double: "\u255b",
        box_drawings_vertical_single_and_right_double: "\u255e",
        box_drawings_vertical_single_and_left_double: "\u2561",
        box_drawings_down_single_and_horizontal_double: "\u2564",
        box_drawings_up_single_and_horizontal_double: "\u2567",
        box_drawings_vertical_single_and_horizontal_double: "\u256a"
    }

    # initialization
    def initialize
      @data_hash = {}
      @console_output = Kernel32Lib.GetStdHandle(Kernel32Lib::STD_OUTPUT_HANDLE)
      Kernel32Lib.set_console_window_info(@console_output,true,[0,0,1,1])
      Kernel32Lib.set_console_text_attribute(@console_output,Kernel32Lib::FOREGROUND_WHITE)
      @init_console_screen_buffer_info = Kernel32Lib.get_console_screen_buffer_info(@console_output)
      @init_attributes = @init_console_screen_buffer_info[:attributes]
      @init_screen_buffer_size = @init_console_screen_buffer_info[:size]
    end

    # store data
    #
    # @param key [String] Value in first cell of data row
    # @param values [Array] Values in cells of row
    # @param options [Hash] Options: color styles
    def store(key,values,options)
      @data_hash[key.to_sym] = { values: values, options: DEFAULT_OPTIONS.merge(options) }
    end

    def calc_console_window_size(console_screen_buffer_size)
      console_window_size = []
      console_window_size << 0 << 0
      if console_screen_buffer_size[0] >= @init_console_screen_buffer_info[:maximum_window_size][0]
        console_window_size << @init_console_screen_buffer_info[:maximum_window_size][0]-1
      else
        console_window_size << console_screen_buffer_size[0]-1
      end
      if console_screen_buffer_size[1] >= @init_console_screen_buffer_info[:maximum_window_size][1]
        console_window_size << @init_console_screen_buffer_info[:maximum_window_size][1]-1
      else
        console_window_size << console_screen_buffer_size[1]-1
      end
      console_window_size
    end

    # show view
    #
    # @param header [Array] Header text (with CRLF separated rows)
    # @param fields [Array] Array of metadata: name, max width, format, alignment
    # @param options [Hash] Options: color styles + custom parameters
    def show(header,fields,options)
      opts = DEFAULT_OPTIONS.merge(options)

      head_box_lines = []
      head_box_lines << [] << []
      @data_box_lines = []
      @data_box_lines << [] << []
      fields.each { |field|
        head_box_lines[0] << (DEFAULT_SYMBOLS[:box_drawings_double_horizontal]*field[:max_width])
        @data_box_lines[0] << (DEFAULT_SYMBOLS[:box_drawings_light_horizontal]*field[:max_width])
        @data_box_lines[1] << (DEFAULT_SYMBOLS[:box_drawings_double_horizontal]*field[:max_width])
        head_box_lines[1] << (DEFAULT_SYMBOLS[:box_drawings_double_horizontal]*field[:max_width])
      }
      h0_str = "#{DEFAULT_SYMBOLS[:box_drawings_down_single_and_right_double]}#{head_box_lines[0].join(DEFAULT_SYMBOLS[:box_drawings_down_single_and_horizontal_double])}#{DEFAULT_SYMBOLS[:box_drawings_down_single_and_left_double]}"

      @console_screen_buffer_size = [h0_str.length,header.length + opts[:title_lines].length + head_box_lines.length + 1]
      console_window_size = calc_console_window_size(@console_screen_buffer_size)

      system('cls')
      Kernel32Lib.set_console_text_attribute(@console_output,opts[:header_color_style])
      Kernel32Lib.set_console_screen_buffer_size(@console_output,@console_screen_buffer_size)
      Kernel32Lib.set_console_window_info(@console_output,true,console_window_size)

      opts[:title_lines].each { |line|
        print_value "#{line.gsub('_','').center(@console_screen_buffer_size[0],DEFAULT_SYMBOLS[:light_shade])}",opts[:title_color_style]
      }

      print_value h0_str,opts[:header_color_style]
      header.each { |header_line_array|
        print_value "#{DEFAULT_SYMBOLS[:box_drawings_light_vertical]}#{header_line_array.join(DEFAULT_SYMBOLS[:box_drawings_light_vertical])}#{DEFAULT_SYMBOLS[:box_drawings_light_vertical]}"
      }
      print_value "#{DEFAULT_SYMBOLS[:box_drawings_vertical_single_and_right_double]}#{head_box_lines[1].join(DEFAULT_SYMBOLS[:box_drawings_vertical_single_and_horizontal_double])}#{DEFAULT_SYMBOLS[:box_drawings_vertical_single_and_left_double]}"

      @data_cursor_position = Kernel32Lib.get_console_screen_buffer_info(@console_output)[:cursor_position]
    end

    # update view
    def update
      console_screen_buffer_size = [@console_screen_buffer_size[0],@console_screen_buffer_size[1] + @data_hash.keys.length * 2]
      console_window_size = calc_console_window_size(console_screen_buffer_size)

      Kernel32Lib.set_console_screen_buffer_size(@console_output,console_screen_buffer_size)
      Kernel32Lib.set_console_window_info(@console_output,true,console_window_size)
      Kernel32Lib.set_console_cursor_position(@console_output,@data_cursor_position)

      end_line_str = "#{DEFAULT_SYMBOLS[:box_drawings_up_single_and_right_double]}#{@data_box_lines[1].join(DEFAULT_SYMBOLS[:box_drawings_up_single_and_horizontal_double])}#{DEFAULT_SYMBOLS[:box_drawings_up_single_and_left_double]}"
      line_str = "#{DEFAULT_SYMBOLS[:box_drawings_light_vertical_and_right]}#{@data_box_lines[0].join(DEFAULT_SYMBOLS[:box_drawings_light_vertical_and_horizontal])}#{DEFAULT_SYMBOLS[:box_drawings_light_vertical_and_left]}"
      keys = @data_hash.keys.sort
      keys.each_with_index { |key,ind|
        print_value DEFAULT_SYMBOLS[:box_drawings_light_vertical],@data_hash[key][:options][:border_color_style]
        @data_hash[key][:values].each { |val|
          print_value val,@data_hash[key][:options][:data_color_style]
          print_value DEFAULT_SYMBOLS[:box_drawings_light_vertical],@data_hash[key][:options][:border_color_style]
        }
        if ind == keys.length - 1
          print_value end_line_str
        else
          print_value line_str
        end
      }
    end

    # print value
    #
    # @param value [String] Value for printing
    # @param attributes [Integer] Color style
    def print_value(value,attributes=nil)
      Kernel32Lib.set_console_text_attribute(@console_output,attributes) if attributes
      print value
    end

    # close view
    def close
      Kernel32Lib.set_console_text_attribute(@console_output,@init_attributes.to_i)
      Kernel32Lib.set_console_screen_buffer_size(@console_output,@init_screen_buffer_size)
    end
  end
end

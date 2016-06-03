# encoding: utf-8

# Formatting module
# left/right alignment and justified alignment configurable functions
module Formatting
  # constants
  REPL_STR = '~' # replacement string value
  PAD_STR = ' ' # padding string value

  # @param value [String] String value for formatting
  # @param width [Integer] Width in chars for justified alignment
  # @param just [String] Type of alignment: left, right, center. Default: left
  # @return [String] Formatted string value
  def self.format_value_by_width_and_just(value,width,just)
    value = value.strip.length > width ? (value.strip[0..width-Formatting::REPL_STR.length-1]+Formatting::REPL_STR) : value.strip
    case just
      when 'left' then value.ljust(width,Formatting::PAD_STR)
      when 'right' then value.rjust(width,Formatting::PAD_STR)
      when 'center' then value.center(width,Formatting::PAD_STR)
      else
        value.ljust(width,Formatting::PAD_STR)
    end
  end

  # CellFormatter class
  # format data in cell
  class CellFormatter
    # @param [String] String value for formatting
    # @param opts [Hash] options: format, max width, alignment
    # @return [String] Formatted string value
    def self.format_value(value,opts)
      if opts.has_key?(:format)
        cell = sprintf(opts[:format],value)
      else
        cell = sprintf("%#{opts[:max_width]}s",value)
      end
      Formatting.format_value_by_width_and_just(cell,opts[:max_width],opts[:just])
    end
  end

  # CellFormatter class
  # format field name in header
  class HeaderFormatter
    # @param [String] String value for formatting
    # @param opts [Hash] options: format, max width, alignment
    # @return [String] Formatted string value
    def self.format_value(value,opts)
      field = value.gsub('_',' ')
      Formatting.format_value_by_width_and_just(field,opts[:max_width],opts[:just])
    end
  end
end

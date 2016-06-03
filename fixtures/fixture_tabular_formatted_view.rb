# encoding: utf-8

require 'thwait'
#require 'tabular_formatted_view'
require(File.expand_path('../../lib/tabular_formatted_view',__FILE__))

# Fixture module
# test fixture
module Fixture

  # constants
  # fields metadata: name, max width, format, alignment
  FIELDS = [
    { name: 'id', max_width: 30, just: 'center' },
    { name: 'x', max_width: 10, format: '%10.2f', just: 'left' },
    { name: 'state', max_width: 7, just: 'right' },
    { name: 'date', max_width: 20},
    { name: 'timeout', max_width: 10, format: '%5.2f'},
  ]

  # text of header
  HEADER_TEXT = <<-HEAD
id|x+1|state|время (time)|timeout
_|_|_|_|_
  HEAD

  # text of title
  TITLE_TEXT = <<-TITLE
Тест класса "TabularFormattedView"
Test of class "TabularFormattedView"
_
  TITLE

  # show fixture
  def self.show
    # split text of header into single lines array
    view_headers = []
    Fixture::HEADER_TEXT.split("\n").each { |line|
      fields_array = []
      line.split('|').each_with_index { |fld,ind|
        fields_array << Formatting::HeaderFormatter.format_value(fld,Fixture::FIELDS[ind])
      }
      view_headers << [fields_array]
    }

    # initialize view
    tfv = Viewing::TabularFormattedView.new

    # show view with header, metadata and title
    tfv.show(view_headers,Fixture::FIELDS,{ title_lines: Fixture::TITLE_TEXT.split("\n") })

    # initialize proxy
    vp = Viewing::ViewProxy.new(tfv)

    # start thread for update loop
    vp.update('view')

    # start producers threads
    threads = []
    30.times { |obj|
      threads << Thread.new {
        thr = Thread.current
        thr[:id] = "Thread #{thr.object_id}"
        res = 0
        timeout = rand(obj*0.05)
        thr[:timeout] = timeout
        obj.times { |x|
          view_values = []
          [thr[:id],x+1,thr.status == 'run' ? 'вып.' : 'ост.',Time.now,timeout].each_with_index { |val, val_i|
            view_values << Formatting::CellFormatter.format_value(val,Fixture::FIELDS[val_i])
          }
          vp.store(thr[:id],view_values,{ data_color_style: Kernel32Lib::FOREGROUND_GREEN | Kernel32Lib::FOREGROUND_INTENSITY | Kernel32Lib::BACKGROUND_BLUE})
          res = x+1
          sleep(timeout)
        }
        thr[:result] = res
      }
    }

    # waiting
    ThreadsWait.all_waits(*threads) { |thr|
      thr.join
      view_values = []
      [thr[:id],thr[:result],thr.status == 'run' ? 'вып.' : 'ост.',Time.now,thr[:timeout]].each_with_index { |val, val_i|
        view_values << Formatting::CellFormatter.format_value(val,Fixture::FIELDS[val_i])
      }
      vp.store(thr[:id],view_values,{ data_color_style: (thr.status.to_s == 'false' ? Kernel32Lib::FOREGROUND_RED | Kernel32Lib::BACKGROUND_RED | Kernel32Lib::FOREGROUND_INTENSITY : 0) })
    }

    # one second
    sleep(1)

    # close proxy and target view
    vp.close
  end
end
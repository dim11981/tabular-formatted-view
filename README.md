# tabular-formatted-view: tabular-formatted-view lib

View some data in simple color tabular form in Windows console

### Installation and usage


Install:

```
gem install tabular-formatted-view
```

Usage:

```ruby
    # initialize view
    tfv = Viewing::TabularFormattedView.new

    # show view with header, fields and options
    header =  <<-HEAD
field 1 p1|field 2 p1|field n
field 1 p2|field 2 p2|_
      HEAD
    fields = [
      { name: 'field 1', max_width: 10, just: 'left' },
      { name: 'field 2', max_width: 7, just: 'right' },
      { name: 'field n', max_width: 10, format: '%10.2f', just: 'center' }
    ]
    opts = { title_lines: ['line 1','line 2','line n'] }
    tfv.show(header.split("\n"),fields,opts)

    # you can initialize and start view proxy
    # vp = Viewing::ViewProxy.new(tfv)
    # vp.update('view')

    # store data in view
    values = ['id 1','abc',0.1]
    id = values[0]
    opts = { data_color_style: Kernel32Lib::FOREGROUND_GREEN | Kernel32Lib::FOREGROUND_INTENSITY | Kernel32Lib::BACKGROUND_BLUE}
    # vp.store(id,values,opts)
    tfv.store(id,values,opts)

    # update view
    # vp.update
    tfv.update

    # close view
    # vp.close
    tfv.close
```

More detailed example in ./fixtures/fixture_tabular_formatted_view.rb

### Troubleshooting

Visit to [tabular-formatted-view homepage](https://github.com/dim11981/tabular-formatted-view)

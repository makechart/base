fontlib = proxise.once ({manager}) ->
  manager.from {name: \@plotdb/konfig, version: \main, path: 'font/index.html'}, {}
    .then (o) -> fontlib.object = (d) -> o.interface.object(d)
    .catch ->
      console.warn """
      [@plotdb/chart] @plotdb/konfig font widget is required for correct font rendering,
      but it's not found. The font family may not be as expected."""
module.exports =
  pkg:
    name: 'base', version: '0.0.1'
    dependencies: [
      {name: "d3", version: "7.9.0", path: "dist/d3.min.js", async: false}
      {name: "@loadingio/debounce.js", version: "main", path: "index.min.js"}
      {name: "wrap-svg-text", version: "main", path: "index.min.js", async: false}
      {name: "@plotdb/layout", version: "main", path: "index.min.js", async: false}
      {name: "@plotdb/layout", version: "main", path: "index.min.css", type: \css}
      {name: "ldcolor", version: "main", path: "index.min.js", async: false}
      {name: "@plotdb/chart", version: "main", path: "index.min.js", async: false}
      {name: "@plotdb/chart", version: "main", path: "index.min.css", type: \css}
      {name: "@plotdb/chart", version: "main", path: "utils/config.js"}
      {name: "@plotdb/chart", version: "main", path: "utils/legend.js"}
      {name: "@plotdb/chart", version: "main", path: "utils/legend.css", type: \css}
      {name: "@plotdb/chart", version: "main", path: "utils/tint.js"}
      {name: "@plotdb/chart", version: "main", path: "utils/tick.js"}
      {name: "@plotdb/chart", version: "main", path: "utils/format.js", async: false}
      {name: "@plotdb/chart", version: "main", path: "utils/axis.js"}
      {name: "@plotdb/chart", version: "main", path: "utils/tip.js"}
    ]
    i18n:
      "zh-TW":
        "x axis": "X軸"
        name: "名稱"

  init: ({root, context, pubsub, data, manager}) ->
    {d3,chart} = context
    pubsub.on \init, (opt = {}) ~>
      opt = {
        root: root
        delay-render: true
        auto-select: true
        data-accessor: -> d3.select(it).datum!._raw
      } <<< opt
      original-init = opt.mod.init
      original-resize = opt.mod.resize
      opt.mod.init = ->
        @random = d3.randomUniform.source(d3.randomLcg(123))(0, 1)
        ret = original-init.apply @
        return if @cfg.font => fontlib {manager} else Promise.resolve!
      opt.mod.resize = ->
        @root.style.background = @cfg.background if @cfg.background?
        @root.style.color = @cfg.color if @cfg.color?
        @root.style.padding = "#{@cfg.margin}px"
        if @cfg.font =>
          if @cfg.font.size? =>
            # set font size separatedly for layout and svg
            # so the downloaded / rasterized svg keep the customized font size.
            if @layout =>
              @layout.root!querySelector('[data-type=layout]').style.fontSize = @cfg.font.size
            @svg.style.fontSize = @cfg.font.size
          #if @cfg.font.family => @cfg.font.family.sync @svg.textContent
          if @cfg.font.family and fontlib.object =>
            fontlib.object(@cfg.font.family).then ~> it.sync @svg.textContent
          @root.setAttribute \class, (
            Array.from(@root.classList)
              .filter -> !/^xfl/.exec(it)
              .filter -> it
              .join(' ') + (if (@cfg.font.family or {}).className => (' ' + @cfg.font.family.className) else '')
          )
          @svg.setAttribute \class, (
            Array.from(@svg.classList)
              .filter -> !/^xfl/.exec(it)
              .filter -> it
              .join(' ') + (if (@cfg.font.family or {}).className => (' ' + @cfg.font.family.className) else '')
          )
        if original-resize => original-resize.apply @
      @chart = c = new chart(opt <<< data)
      c.init!
        .then ->
          if !(data.raw and data.binding) => return
          return c.set-raw data.raw, data.binding
        .then -> c
    @

  interface: -> @chart
  mod: (root) -> {config: {}, dimension: {}, init: (->), resize: (->), render: (->)}

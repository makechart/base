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
      {name: "d3", version: "4", path: "build/d3.min.js", async: false}
      {name: "d3-selection", version: "2", path: "dist/d3-selection.min.js", async: false}
      {name: "d3-random", version: "2", path: "dist/d3-random.min.js"}
      {name: "d3-dispatch", version: "2", path: "dist/d3-dispatch.min.js", async: false}
      {name: "d3-transition", version: "3", path: "dist/d3-transition.min.js"}
      {name: "d3-format", version: "2", path: "dist/d3-format.min.js"}
      {name: "d3-array", version: "2", async: false, path: "dist/d3-array.min.js"}
      {name: "d3-color", version: "2", path: "dist/d3-color.min.js"}
      {name: "d3-path", version: "2", path: "dist/d3-path.min.js"}
      {name: "d3-shape", version: "2", path: "dist/d3-shape.min.js"}
      {name: "d3-interpolate", version: "3", async: false, path: "dist/d3-interpolate.min.js"}
      {name: "d3-scale-chromatic", version: "1", path: "dist/d3-scale-chromatic.min.js"}
      {name: "d3-ease", version: "2", path: "dist/d3-ease.min.js"}
      {name: "d3-quadtree", version: "2", path: "dist/d3-quadtree.min.js"}
      {name: "d3-timer", version: "2", path: "dist/d3-timer.min.js"}
      {name: "d3-force", version: "2", async: false, path: "dist/d3-force.min.js"}
      {name: "d3-hierarchy", version: "2", path: "dist/d3-hierarchy.min.js"}
      {name: "d3-force-boundary", version: "0.0.1", path: "dist/d3-force-boundary.min.js"}
      {name: "d3-drag", version: "2", path: "dist/d3-drag.min.js"}
      {name: "d3-brush", version: "2", path: "dist/d3-brush.min.js"}
      {name: "d3-axis", version: "2", path: "dist/d3-axis.min.js"}
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
      c.init!then -> c
    @

  interface: -> @chart
  mod: (root) -> {config: {}, dimension: {}, init: (->), resize: (->), render: (->)}

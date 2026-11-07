fontlib = proxise.once ({manager}) ->
  manager.from {name: \@plotdb/konfig, version: \main, path: 'font/index.html'}, {}
    .then (o) -> fontlib.object = (d) -> o.interface.object(d)
    .catch ->
      console.warn """
      [@plotdb/chart] @plotdb/konfig font widget is required for correct font rendering,
      but it's not found. The font family may not be as expected."""
# 與 d3.randomLcg 相同的序列 ( 移植自 d3-random, ISC ), 這樣 lite 版不帶 d3 也拿得到一樣的 @random
lcg = (seed) ->
  [mul, inc, eps] = [0x19660D, 0x3C6EF35F, 1 / 0x100000000]
  state = (if 0 <= seed and seed < 1 => seed / eps else Math.abs(seed)) .|. 0
  -> eps * ((state := (mul * state + inc) .|. 0) .>>>. 0)

# lite/index.html 會在這段之前先設 `lite = true` ( 見 src/lite/index.pug ): 不帶 d3, @plotdb/chart 改用
# 單一 bundle ( 內含 debounce 與取代 d3 的 scale / brush / anim / format ).
# 沒設就是原本的完整版, 給既有的圖用.
deps = if lite? => [
  {name: "wrap-svg-text", version: "main", path: "index.min.js", async: false}
  {name: "@plotdb/layout", version: "main", path: "index.min.js", async: false}
  {name: "@plotdb/layout", version: "main", path: "index.min.css", type: \css}
  {name: "ldcolor", version: "main", path: "index.min.js", async: false}
  {name: "@plotdb/chart", version: "main", path: "bundle.min.js", async: false}
  {name: "@plotdb/chart", version: "main", path: "bundle.min.css", type: \css}
] else [
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

module.exports =
  pkg:
    name: 'base', version: '0.0.1'
    dependencies: deps
    i18n:
      "zh-TW":
        "x axis": "X軸"
        name: "名稱"

  init: ({root, context, pubsub, data = {}, manager}) ->
    {chart} = context
    pubsub.on \init, (opt = {}) ~>
      opt = {
        root: root
        delay-render: true
        auto-select: true
        # 等同 d3.select(it).datum!._raw
        data-accessor: -> (it.__data__ or {})._raw
      } <<< opt
      original-init = opt.mod.init
      original-resize = opt.mod.resize
      opt.mod.init = ->
        # 等同 d3.randomUniform.source(d3.randomLcg(123))(0, 1)
        @random = lcg 123
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

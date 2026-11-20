fontlib = proxise.once ({manager}) ->
  manager.from {name: \@plotdb/konfig, version: \main, path: 'font/index.html'}, {data: {}}
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
          # xlfont 的 class ( xfl-* ) 掛在 root 與 svg 上, 字型才會套用
          set-class = (cls) ~>
            [@root, @svg].map (n) ->
              n.setAttribute \class, (
                Array.from(n.classList).filter(-> it and !/^xfl/.exec(it)).join(' ') + (if cls => " #cls" else '')
              )
          family = @cfg.font.family
          name-of = -> if !it => '' else if typeof(it) == \string => it else (it.name or '')
          # 舊的設定可能直接存 xlfont 物件 ( 有 className ). 否則先保留目前的 class, 等載入完再換, 免得每次 resize 都閃一下
          if !family or family.className => set-class (family or {}).className
          if family and fontlib.object =>
            # konfig 的字型元件要帶 name 的物件, 字串要包起來
            fontlib.object(if typeof(family) == \string => {name: family} else family)
              .then (f) ~>
                # 等待中又換了字型就不套
                if name-of((@cfg.font or {}).family) != name-of(family) => return
                # 載入失敗或不是 xlfont 的字型 ( 如系統字型 ) 時是 {}, 沒有 sync / className - 就用瀏覽器的字型
                if !(f and typeof(f.sync) == \function) => return set-class null
                set-class f.className
                f.sync @svg.textContent
              .catch (e) ->
                console.warn "[@makechart/base] failed to load font #{family.name or family}:", e
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

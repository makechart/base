(function(){
  var fontlib;
  fontlib = proxise.once(function(arg$){
    var manager;
    manager = arg$.manager;
    return manager.from({
      name: '@plotdb/konfig',
      version: 'main',
      path: 'font/index.html'
    }, {}).then(function(o){
      return fontlib.object = function(d){
        return o['interface'].object(d);
      };
    })['catch'](function(){
      return console.warn("[@plotdb/chart] @plotdb/konfig font widget is required for correct font rendering,\nbut it's not found. The font family may not be as expected.");
    });
  });
  module.exports = {
    pkg: {
      name: 'base',
      version: '0.0.1',
      dependencies: [
        {
          name: "d3",
          version: "4",
          path: "build/d3.min.js",
          async: false
        }, {
          name: "d3-selection",
          version: "2",
          path: "dist/d3-selection.min.js",
          async: false
        }, {
          name: "d3-random",
          version: "2",
          path: "dist/d3-random.min.js"
        }, {
          name: "d3-dispatch",
          version: "2",
          path: "dist/d3-dispatch.min.js",
          async: false
        }, {
          name: "d3-transition",
          version: "3",
          path: "dist/d3-transition.min.js"
        }, {
          name: "d3-format",
          version: "2",
          path: "dist/d3-format.min.js"
        }, {
          name: "d3-array",
          version: "2",
          async: false,
          path: "dist/d3-array.min.js"
        }, {
          name: "d3-color",
          version: "2",
          path: "dist/d3-color.min.js"
        }, {
          name: "d3-path",
          version: "2",
          path: "dist/d3-path.min.js"
        }, {
          name: "d3-shape",
          version: "2",
          path: "dist/d3-shape.min.js"
        }, {
          name: "d3-interpolate",
          version: "3",
          async: false,
          path: "dist/d3-interpolate.min.js"
        }, {
          name: "d3-scale-chromatic",
          version: "1",
          path: "dist/d3-scale-chromatic.min.js"
        }, {
          name: "d3-ease",
          version: "2",
          path: "dist/d3-ease.min.js"
        }, {
          name: "d3-quadtree",
          version: "2",
          path: "dist/d3-quadtree.min.js"
        }, {
          name: "d3-timer",
          version: "2",
          path: "dist/d3-timer.min.js"
        }, {
          name: "d3-force",
          version: "2",
          async: false,
          path: "dist/d3-force.min.js"
        }, {
          name: "d3-hierarchy",
          version: "2",
          path: "dist/d3-hierarchy.min.js"
        }, {
          name: "d3-force-boundary",
          version: "0.0.1",
          path: "dist/d3-force-boundary.min.js"
        }, {
          name: "d3-drag",
          version: "2",
          path: "dist/d3-drag.min.js"
        }, {
          name: "d3-brush",
          version: "2",
          path: "dist/d3-brush.min.js"
        }, {
          name: "d3-axis",
          version: "2",
          path: "dist/d3-axis.min.js"
        }, {
          name: "@loadingio/debounce.js",
          version: "main",
          path: "index.min.js"
        }, {
          name: "wrap-svg-text",
          version: "main",
          path: "index.min.js",
          async: false
        }, {
          name: "@plotdb/layout",
          version: "main",
          path: "index.min.js",
          async: false
        }, {
          name: "@plotdb/layout",
          version: "main",
          path: "index.min.css",
          type: 'css'
        }, {
          name: "ldcolor",
          version: "main",
          path: "index.min.js",
          async: false
        }, {
          name: "@plotdb/chart",
          version: "main",
          path: "index.min.js",
          async: false
        }, {
          name: "@plotdb/chart",
          version: "main",
          path: "index.min.css",
          type: 'css'
        }, {
          name: "@plotdb/chart",
          version: "main",
          path: "utils/config.js"
        }, {
          name: "@plotdb/chart",
          version: "main",
          path: "utils/legend.js"
        }, {
          name: "@plotdb/chart",
          version: "main",
          path: "utils/legend.css",
          type: 'css'
        }, {
          name: "@plotdb/chart",
          version: "main",
          path: "utils/tint.js"
        }, {
          name: "@plotdb/chart",
          version: "main",
          path: "utils/tick.js"
        }, {
          name: "@plotdb/chart",
          version: "main",
          path: "utils/format.js",
          async: false
        }, {
          name: "@plotdb/chart",
          version: "main",
          path: "utils/axis.js"
        }, {
          name: "@plotdb/chart",
          version: "main",
          path: "utils/tip.js"
        }
      ],
      i18n: {
        "zh-TW": {
          "x axis": "X軸",
          name: "名稱"
        }
      }
    },
    init: function(arg$){
      var root, context, pubsub, data, manager, d3, chart, this$ = this;
      root = arg$.root, context = arg$.context, pubsub = arg$.pubsub, data = arg$.data, manager = arg$.manager;
      d3 = context.d3, chart = context.chart;
      pubsub.on('init', function(opt){
        var originalInit, originalResize, c;
        opt == null && (opt = {});
        opt = import$({
          root: root,
          delayRender: true,
          autoSelect: true,
          dataAccessor: function(it){
            return d3.select(it).datum()._raw;
          }
        }, opt);
        originalInit = opt.mod.init;
        originalResize = opt.mod.resize;
        opt.mod.init = function(){
          var ret;
          this.random = d3.randomUniform.source(d3.randomLcg(123))(0, 1);
          ret = originalInit.apply(this);
          return this.cfg.font
            ? fontlib({
              manager: manager
            })
            : Promise.resolve();
        };
        opt.mod.resize = function(){
          var this$ = this;
          if (this.cfg.background != null) {
            this.root.style.background = this.cfg.background;
          }
          if (this.cfg.color != null) {
            this.root.style.color = this.cfg.color;
          }
          this.root.style.padding = this.cfg.margin + "px";
          if (this.cfg.font) {
            if (this.cfg.font.size != null) {
              if (this.layout) {
                this.layout.root().querySelector('[data-type=layout]').style.fontSize = this.cfg.font.size;
              }
              this.svg.style.fontSize = this.cfg.font.size;
            }
            if (this.cfg.font.family && fontlib.object) {
              fontlib.object(this.cfg.font.family).then(function(it){
                return it.sync(this$.svg.textContent);
              });
            }
            this.root.setAttribute('class', Array.from(this.root.classList).filter(function(it){
              return !/^xfl/.exec(it);
            }).join(' ') + (this.cfg.font.family ? ' ' + this.cfg.font.family.className : ''));
            this.svg.setAttribute('class', Array.from(this.svg.classList).filter(function(it){
              return !/^xfl/.exec(it);
            }).join(' ') + (this.cfg.font.family ? ' ' + this.cfg.font.family.className : ''));
          }
          if (originalResize) {
            return originalResize.apply(this);
          }
        };
        this$.chart = c = new chart(import$(opt, data));
        return c.init().then(function(){
          return c;
        });
      });
      return this;
    },
    'interface': function(){
      return this.chart;
    },
    mod: function(root){
      return {
        config: {},
        dimension: {},
        init: function(){},
        resize: function(){},
        render: function(){}
      };
    }
  };
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
}).call(this);

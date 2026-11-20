# Change Logs

## v0.2.2

 - fix bug: setting `font.family` threw `n.sync is not a function` ( unhandled rejection ) since 0.2.1
   loads the konfig font widget. the widget resolves `{}` when the font can't be loaded from xlfont or
   isn't an xlfont font ( e.g. a system font ). base now only calls `sync` when it exists, and warns
   when loading the font fails
 - fix bug: the `xfl-*` class was read from `cfg.font.family`, which the konfig font widget stores as
   `{name, style, weight}` without `className`, so a loaded xlfont was never applied. the class now
   comes from the resolved font object ( a `cfg.font.family` that already has `className` still works ).
   a string `font.family` is passed to the widget as `{name}`


## v0.2.1

 - fix bug: the `@plotdb/konfig` font widget was never loaded. `manager.from` takes an attach option
   as its 2nd argument, and the widget reads `data.dataSource`; passing `{}` made it throw on
   `undefined.dataSource`, which base swallowed into the "font widget is required" warning.
   pass `{data: {}}` instead. fonts now apply wherever base is used


## v0.2.0

 - add `d3/index.html` and `lite/index.html`. `index.html` is unchanged and still equals
   `d3/index.html`; it will become the lite version in a future breaking release.
 - `lite/index.html` doesn't load d3 or `@loadingio/debounce.js`: it uses `@plotdb/chart`'s
   `bundle.min.js` ( requires the `@plotdb/chart` version with `shape` / `color` / `scale` / `anim` utils ).
 - no longer use d3 in base itself: `data-accessor` reads `node.__data__._raw`, and `@random` uses
   a port of `d3.randomLcg(123)` ( same sequence ).


## v0.1.1

 - add default value to `data` as an object


## v0.1.0

 - upgrade dependant d3 version to 7.9.0
 - call `setRaw` if `raw` and `binding` is available in block data


## v0.0.2

 - check css class before adding it to SVG to prevent `undefined` as a class
 - add `d3-scale` for additional scale function support


## v0.0.1

init release

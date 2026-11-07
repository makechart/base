# Change Logs

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

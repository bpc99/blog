{%- set js_vendors = {} %}
{%- set js_vendors = js_vendors | attr('anime', '{{ theme.vendors.anime }}') %}

{%- if theme.pjax %}
  {%- set js_vendors = js_vendors | attr('pjax', '{{ theme.vendors.pjax }}') %}
{%- endif %}

{%- if theme.fancybox %}
  {%- set js_vendors = js_vendors | attr('jquery', '{{ theme.vendors.jquery }}') %}
  {%- set js_vendors = js_vendors | attr('fancybox', '{{ theme.vendors.fancybox }}') %}
{%- endif %}

{%- if theme.mediumzoom %}
  {%- set js_vendors = js_vendors | attr('mediumzoom', '{{ theme.vendors.mediumzoom }}') %}
{%- endif %}

{%- if theme.lazyload %}
  {%- set js_vendors = js_vendors | attr('lazyload', '{{ theme.vendors.lazyload }}') %}
{%- endif %}

{%- if theme.pangu %}
  {%- set js_vendors = js_vendors | attr('pangu', '//cdn.jsdelivr.net/npm/pangu@4/dist/browser/pangu.min.js') %}
{%- endif %}

{%- if theme.motion.enable %}
  {%- set js_vendors = js_vendors | attr('velocity', '{{ theme.vendors.velocity }}') %}
  {%- set js_vendors = js_vendors | attr('velocity_ui', '{{ theme.vendors.velocity_ui }}') %}
{%- endif %}

{%- if theme.canvas_nest.enable %}
  {%- if theme.canvas_nest.onmobile %}
    {%- set canvas_nest_uri = theme.vendors.canvas_nest or next_vendors('canvas-nest/canvas-nest.min.js') %}
  {% else %}
    {%- set canvas_nest_uri = theme.vendors.canvas_nest_nomobile or next_vendors('canvas-nest/canvas-nest-nomobile.min.js') %}
  {%- endif %}
  <script color='{{ theme.canvas_nest.color }}' opacity='{{ theme.canvas_nest.opacity }}' zIndex='{{ theme.canvas_nest.zIndex }}' count='{{ theme.canvas_nest.count }}' src="{{ canvas_nest_uri }}"></script>
{%- endif %}

{%- if theme.canvas_ribbon.enable %}
  {%- set canvas_ribbon_uri = theme.vendors.canvas_ribbon or next_vendors('canvas-ribbon/canvas-ribbon.js') %}
  <script size="{{ theme.canvas_ribbon.size }}" alpha="{{ theme.canvas_ribbon.alpha }}" zIndex="{{ theme.canvas_ribbon.zIndex }}" src="{{ canvas_ribbon_uri }}"></script>
{%- endif %}

{%- for name, internal in js_vendors %}
  {%- set internal_script = next_vendors(internal) %}
  <script src="{{ theme.vendors[name] or internal_script }}"></script>
{%- endfor %}

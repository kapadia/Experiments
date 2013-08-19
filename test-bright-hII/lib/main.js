// Generated by CoffeeScript 1.6.3
(function() {
  var DOMReady, data, esoButton, onAxis, ruse, xEl, yEl;

  ruse = null;

  xEl = yEl = null;

  data = null;

  esoButton = null;

  onAxis = function() {
    var points, x, y;
    x = xEl.value;
    y = yEl.value;
    points = data.map(function(d) {
      var datum;
      datum = {};
      datum[x] = Math.log(parseFloat(d[x]));
      datum[y] = Math.log(parseFloat(d[y]));
      return datum;
    });
    return ruse.plot(points);
  };

  DOMReady = function() {
    var el, esoButtonEl;
    console.log('DOMReady');
    el = document.querySelector("#ruse");
    xEl = document.querySelector("select.x-axis");
    yEl = document.querySelector("select.y-axis");
    esoButtonEl = document.querySelector('button.eso149');
    ruse = new astro.Ruse(el, 800, 480);
    return $.ajax("Koribalski.BGC.machine.json").done(function(d) {
      data = d;
      xEl.onchange = onAxis;
      yEl.onchange = onAxis;
      xEl.value = 'ra';
      yEl.value = 'dec';
      return onAxis();
    });
  };

  window.addEventListener('DOMContentLoaded', DOMReady, false);

}).call(this);
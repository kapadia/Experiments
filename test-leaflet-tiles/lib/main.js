// Generated by CoffeeScript 1.6.3
(function() {
  var DOMReady;

  DOMReady = function() {
    var layer, map;
    map = L.map('map').setView([-2.51, 34.93], 0);
    layer = L.tileLayer('floor8tiles/{tilename}.jpg');
    layer.getTileUrl = function(tilePoint) {
      var convertTileUrl, url, zoom;
      zoom = this._getZoomForUrl();
      convertTileUrl = function(x, y, s, zoom) {
        var d, e, f, g, pixels;
        pixels = Math.pow(2, zoom);
        d = (x + pixels) % pixels;
        e = (y + pixels) % pixels;
        f = "t";
        g = 0;
        while (g < zoom) {
          pixels = pixels / 2;
          if (e < pixels) {
            if (d < pixels) {
              f += "q";
            } else {
              f += "r";
              d -= pixels;
            }
          } else {
            if (d < pixels) {
              f += "t";
              e -= pixels;
            } else {
              f += "s";
              d -= pixels;
              e -= pixels;
            }
          }
          g++;
        }
        return {
          x: x,
          y: y,
          src: f,
          s: s
        };
      };
      url = convertTileUrl(tilePoint.x, tilePoint.y, 1, zoom);
      return "floor8tiles/" + url.src + ".jpg";
    };
    return layer.addTo(map);
  };

  window.addEventListener('DOMContentLoaded', DOMReady, false);

}).call(this);

// Generated by CoffeeScript 1.6.3
(function() {
  var DOMReady;

  DOMReady = function() {
    var url;
    url = "http://s3.amazonaws.com/radio.galaxyzoo.org/beta/subjects/raw/S1083.fits.gz";
    return new astro.FITS(url, function(f) {
      return console.log(f);
    });
  };

  window.addEventListener('DOMContentLoaded', DOMReady, false);

}).call(this);

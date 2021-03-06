// Generated by CoffeeScript 1.6.3
(function() {
  var DOMReady, canvas, context, counter, getSubjects, isSimulation, maxSubjects;

  canvas = null;

  context = null;

  counter = null;

  maxSubjects = 1000;

  window.maskValues = [];

  isSimulation = function(subject) {
    if (subject.metadata.training[0].type === 'empty') {
      return false;
    } else {
      return true;
    }
  };

  getSubjects = function() {
    return $.ajax("https://api.zooniverse.org/projects/spacewarp/groups/5154a3783ae74086ab000002/subjects?limit=10").done(function(subjects) {
      var checkMask;
      counter = subjects.length - 1;
      checkMask = function(subject) {
        var metadata, x, xhr, y;
        if (isSimulation(subject)) {
          metadata = subject.metadata.training[0];
          x = metadata.x;
          y = metadata.y;
          xhr = new XMLHttpRequest();
          xhr.open('GET', subject.location.standard);
          xhr.responseType = 'blob';
          xhr.onload = function() {
            var img, url;
            url = window.URL.createObjectURL(xhr.response);
            img = new Image();
            img.onload = function(e) {
              var pixel;
              canvas.width = img.width;
              canvas.height = img.height;
              context.drawImage(img, 0, 0);
              pixel = context.getImageData(x, img.height - y, 1, 1);
              maskValues.push(pixel.data[3]);
              counter -= 1;
              maxSubjects -= 1;
              if (counter === 0) {
                if (maxSubjects > 0) {
                  getSubjects();
                }
                return;
              }
              return checkMask(subjects[counter]);
            };
            return img.src = url;
          };
          return xhr.send();
        } else {
          counter -= 1;
          maxSubjects -= 1;
          if (counter === 0) {
            if (maxSubjects > 0) {
              getSubjects();
            }
            return;
          }
          return checkMask(subjects[counter]);
        }
      };
      return checkMask(subjects[counter]);
    });
  };

  DOMReady = function() {
    console.log('DOMReady');
    canvas = document.querySelector('canvas');
    context = canvas.getContext('2d');
    return getSubjects();
  };

  window.addEventListener('DOMContentLoaded', DOMReady, false);

}).call(this);

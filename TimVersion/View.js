// Generated by IcedCoffeeScript 1.3.1b
var View,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

View = (function() {

  View.name = 'View';

  View.BOX = 1;

  View.PAN = 2;

  function View(canvas3dctx, canvas2dctx) {
    this.notify = __bind(this.notify, this);

    this.register = __bind(this.register, this);

    this.scrolling = __bind(this.scrolling, this);

    this.changeMode = __bind(this.changeMode, this);
    this.handlers = {
      'translate': null
    };
    this.span = {
      'RAMin': 0,
      'RAMax': .256,
      'DecMin': -.256,
      'DecMax': .256
    };
    this.requestBounds = {
      'RAMin': 0,
      'RAMax': 0,
      'DecMin': 0,
      'DecMax': 0
    };
    this.sdss = null;
    this.overlays = [];
    this.first = null;
    this.box = null;
    this.canvas2d = canvas2dctx;
    this.gl = canvas3dctx;
    this.camera = {
      "x": 0.0,
      "y": 0.0,
      "z": 2.414213562
    };
    this.displayColor = {
      "R": 0,
      "G": 0,
      "B": 0,
      "A": 1
    };
  }

  View.prototype.requestSDSS = function() {
    this.sdss = new SDSSOverlay(this.gl);
    this.sdss.requestImages(this.span);
    return this.overlays.push(this.span);
  };

  View.prototype.requestFIRST = function() {
    this.first = new Overlay(this.gl);
    this.first.requestImages(this.span);
    return this.overlays.push(this.first);
  };

  View.prototype.requestBox = function(cb) {
    this.box = new BoxOverlay(this.canvas2d);
    this.box.onBox = cb;
    return this.overlays.push(this.box);
  };

  View.prototype.changeMode = function(mode) {
    var canvas;
    if (mode === 1) {
      this.box.setEvents("skycanvas2");
      return Util.prototype.unhookEvent('skycanvas2', 'mousewheel', this.scrolling);
    } else if (mode === 2) {
      this.overlays[0].setEvents("skycanvas2", this);
      return Util.prototype.hookEvent('skycanvas2', 'mousewheel', this.scrolling);
    } else {
      canvas = document.getElementById('skycanvas2');
      canvas.onmousemove = null;
      canvas.onmouseup = null;
      return canvas.onmousedown = null;
    }
  };

  View.prototype.translate = function(x, y, z) {
    if (-this.camera.x - x > 0) this.camera.x += x;
    if (this.camera.y + y > -90 && this.camera.y + y < 90) this.camera.y += y;
    this.camera.z += z;
    return this.notify('translate');
  };

  View.prototype.display = function() {
    var overlay, _i, _len, _ref;
    this.gl.viewport(0, 0, this.gl.width, this.gl.height);
    this.gl.clear(this.gl.COLOR_BUFFER_BIT | this.gl.DEPTH_BUFFER_BIT);
    this.gl.clearColor(this.displayColor.R, this.displayColor.G, this.displayColor.B, this.displayColor.A);
    this.gl.perspectiveMatrix.makeIdentity();
    this.gl.perspectiveMatrix.perspective(45, 1, 0.01, 100);
    this.gl.perspectiveMatrix.lookat(this.camera.x, this.camera.y, this.camera.z, this.camera.x, this.camera.y, 0, 0, 1, 0);
    _ref = this.overlays;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      overlay = _ref[_i];
      overlay.display(this.getBounds());
    }
    return this.gl.flush();
  };

  View.prototype.withinSpan = function(bound) {
    return (bound.RAMax < this.span.RAMax) && (bound.RAMin > this.span.RAMin) && (bound.DecMax < this.span.DecMax) && (bound.DecMin > this.span.DecMin);
  };

  View.prototype.requestBoundExpansion = function(side) {
    var overlay, _i, _len, _ref, _results;
    if (side === 1) {
      this.requestBounds.RAMin = this.span.RAMin;
      this.requestBounds.RAMax = this.span.RAMax;
      this.requestBounds.DecMin = this.span.DecMax;
      this.requestBounds.DecMax = this.span.DecMax = this.span.DecMax + .512;
    } else if (side === 3) {
      this.requestBounds.RAMin = this.span.RAMin;
      this.requestBounds.RAMax = this.span.RAMax;
      this.requestBounds.DecMax = this.span.DecMin;
      this.requestBounds.DecMin = this.span.DecMin = this.span.DecMin(-.512);
    } else if (side === 2) {
      this.requestBounds.DecMax = this.span.DecMax;
      this.requestBounds.DecMin = this.span.DecMin;
      this.requestBounds.RAMax = this.span.RAMin;
      this.requestBounds.RAMin = this.span.RAMin = this.span.RAMin - .512;
    } else if (side === 4) {
      this.requestBounds.DecMax = this.span.DecMax;
      this.requestBounds.DecMin = this.span.DecMin;
      this.requestBounds.RAMin = this.span.RAMax;
      this.requestBounds.RAMax = this.span.RAMax = this.span.RAMax + .512;
    } else {
      return;
    }
    _ref = this.overlays;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      overlay = _ref[_i];
      _results.push(overlay.requestImages(this.requestBounds));
    }
    return _results;
  };

  /*
  	FUNCTION: getBounds()
  
  	returns: Will return the bounding box of the camera. This box is based on a 1024x1024 viewing pane. Any smaller / larger, and it will still
  	assume this
  */


  View.prototype.getBounds = function() {
    var boundingBox, center, height, width;
    center = {
      'RA': -this.camera.x * .256,
      'DEC': -this.camera.y * .256
    };
    height = width = this.camera.z / 2.414213562 * 1.8 * .512;
    boundingBox = {
      'RAMin': center.RA - width / 2,
      'RAMax': center.RA + width / 2,
      'DecMin': center.DEC - height / 2,
      'DecMax': center.DEC + height / 2
    };
    return boundingBox;
  };

  View.prototype.scrolling = function(event) {
    var delta;
    delta = 0;
    if (!event) event = window.event;
    if (event.wheelDelta) {
      delta = event.wheelDelta / 60;
    } else if (event.detail) {
      delta = -event.detail / 2;
    }
    if (delta > 0 && this.camera.z >= 1.8) {
      return this.translate(0, 0, -.3);
    } else if (delta <= 0) {
      return this.translate(0, 0, .3);
    }
  };

  View.prototype.register = function(type, callback) {
    var oldLoaded;
    oldLoaded = this.handlers[type];
    if (this.handlers[type]) {
      return this.handlers[type] = function(view) {
        if (oldLoaded) oldLoaded(view);
        return callback(view);
      };
    } else {
      return this.handlers[type] = callback;
    }
  };

  View.prototype.notify = function(type) {
    if (this.handlers[type]) return this.handlers[type](this);
  };

  return View;

})();

// Generated by CoffeeScript 1.3.1
var BoxOverlay;

BoxOverlay = (function() {

  BoxOverlay.name = 'BoxOverlay';

  function BoxOverlay(canvasid) {
    this.canvas = document.getElementById(canvasid);
    this.ctx = this.canvas.getContext('2d');
    this.ctx.fillStyle = "rgba(0,0,200,.5)";
    this.start = 0;
    this.draw = false;
    this.enabled = true;
    this.end = 0;
    this.canvas.relMouseCoords = function(event) {
      var canvasX, canvasY, currentElement, totalOffsetX, totalOffsetY;
      totalOffsetX = 0;
      totalOffsetY = 0;
      canvasX = 0;
      canvasY = 0;
      currentElement = this;
      while (currentElement = currentElement.offsetParent) {
        totalOffsetX += currentElement.offsetLeft;
        totalOffsetY += currentElement.offsetTop;
      }
      canvasX = event.pageX - totalOffsetX;
      canvasY = event.pageY - totalOffsetY;
      return {
        x: canvasX,
        y: canvasY
      };
    };
    this.onBox = null;
  }

  BoxOverlay.prototype.setEvents = function(canvasid) {
    var _this = this;
    this.canvas.onmousedown = function(event) {
      if (!_this.enabled) {
        return;
      }
      _this.start = _this.canvas.relMouseCoords(event);
      return _this.draw = true;
    };
    this.canvas.onmousemove = function(event) {
      if (_this.draw && _this.enabled) {
        return _this.end = _this.canvas.relMouseCoords(event);
      }
    };
    return this.canvas.onmouseup = function(event) {
      if (!_this.enabled) {
        return;
      }
      _this.end = _this.canvas.relMouseCoords(event);
      _this.ctx.clearRect(0, 0, _this.canvas.width, _this.canvas.height);
      if (_this.onBox) {
        _this.onBox({
          start: _this.start,
          end: _this.end
        });
      }
      return _this.draw = false;
    };
  };

  BoxOverlay.prototype.display = function(bound) {
    if (this.draw) {
      this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
      return this.ctx.fillRect(this.start.x, this.start.y, this.end.x - this.start.x, this.end.y - this.start.y);
    }
  };

  return BoxOverlay;

})();

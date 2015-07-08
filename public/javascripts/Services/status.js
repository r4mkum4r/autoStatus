var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

angular.module('Services').factory('Status', function(Form) {
  var Status;
  Status = (function(superClass) {
    extend(Status, superClass);

    function Status() {
      return Status.__super__.constructor.apply(this, arguments);
    }

    Status.prototype.submit = function(data) {
      return console.log(this);
    };

    return Status;

  })(Form);
  return new Status;
});

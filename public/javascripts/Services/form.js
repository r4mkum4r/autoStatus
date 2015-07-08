angular.module('Services').service('Form', function() {
  var Form;
  return Form = (function() {
    function Form() {}

    Form.prototype.post = function() {
      return console.log('post');
    };

    Form.prototype.get = function() {
      return console.log('get');
    };

    return Form;

  })();
});

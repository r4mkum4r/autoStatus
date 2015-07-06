angular.module('Controllers').controller('statusCtrl', function($scope, Status) {
  $scope.options = {
    resize_enabled: false,
    removePlugins: 'elementspath',
    toolbar: [['Bold', 'Italic', '-', 'Cut', 'Copy', 'Paste', '-', 'Undo', 'Redo', '-', 'BulletedList', 'NumberedList', '-', 'Link']]
  };
  $scope.status = {};
  return $scope.submit = function() {
    if ($scope.statusForm.$invalid) {
      return;
    }
    return Status.submit();
  };
});

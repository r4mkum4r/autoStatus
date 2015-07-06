angular.module 'Controllers'
.controller 'statusCtrl', ($scope, Status)->
  $scope.options =
    resize_enabled : false
    removePlugins  : 'elementspath'
    toolbar        : [
      [ 'Bold', 
        'Italic', 
        '-', 
        'Cut', 
        'Copy', 
        'Paste', 
        '-', 
        'Undo', 
        'Redo' , 
        '-', 
        'BulletedList', 
        'NumberedList' ,
        '-',
        'Link' 
      ]
  ]
  $scope.status = {}

  $scope.submit = ->

    return if $scope.statusForm.$invalid

    Status.submit()




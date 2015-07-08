angular.module 'Services'
.factory 'Status', (Form)->
  class Status extends Form

    submit : (data) ->

      console.log @


  new Status


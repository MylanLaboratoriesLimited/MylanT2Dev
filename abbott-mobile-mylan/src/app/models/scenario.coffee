Entity = require 'models/entity'

class Scenario extends Entity
  @table: 'Scenario'
  @description: 'Scenario'

  @schema: ->
    [
      {local:'id', sfdc:'Id'}
      {local:'name', indexWithType:'string'}
      {local:'structure'}
    ]

module.exports = Scenario
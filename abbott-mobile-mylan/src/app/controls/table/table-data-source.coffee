class TableDatasource
  numberOfRowsForTable: (table) -> throw 'Should be overridden.'

  cellForObjectOnTable: (object, table) -> throw 'Should be overridden.'

  batchSize: -> 500

  createCollection: -> throw 'Should be overridden.'

  createTableHeaderItemsForModel: (model) -> throw 'Should be overridden.'

module.exports = TableDatasource
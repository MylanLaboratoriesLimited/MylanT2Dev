Spine = require 'spine'
ActivityIndicator = require 'common/activity-indicator'
TableHeadersList = require 'controls/table/table-header/table-headers-list'
TableController = require 'controls/table/table-controller'
Utils = require 'common/utils'

class LazyTableController extends Spine.Controller
  didRender: false
  spinner: null
  tableView: null
  collection: null
  tableHeader: null
  fetchResponse: null
  searchString: null
  cellsBatchSize: 100
  currentNumberOfRows: 100
  defaultBatchSize: 500
  defaultSortingHeader: null

  _createTable: ->
    new TableController

  constructor: ->
    super
    @spinner = new ActivityIndicator @el[0]
    @_initCollection()

  active: (params) ->
    super
    @_initCollection()
    searchFilter = params?.search ? null
    if not @didRender
      @searchString = searchFilter
      @render()
    else if @_shouldSearchWithFilter searchFilter
      @searchString = searchFilter
      @reload()

  _initCollection: ->
    @collection = @datasource.createCollection()
    @collection.pageSize = @datasource.batchSize?() ? @defaultBatchSize

  saveSortingHeader: =>
    @defaultSortingHeader = @tableHeader?.activeController

  _shouldSearchWithFilter: (searchFilter) ->
    searchFilter and ((@searchString and searchFilter.toLowerCase() isnt @searchString.toLowerCase()) or not @searchString)

  getAllEntities: =>
    @collection.getAllEntitiesFromResponse @fetchResponse

  render: ->
    @_initTableHeader()
    @_initTable()
    @reload()
    @didRender = true
    @

  _initTableHeader: ->
    tableHeaderItems = @datasource.createTableHeaderItemsForModel(@collection.model)
    if tableHeaderItems?.length > 0
      @tableHeader = new TableHeadersList tableHeaderItems, @defaultSortingHeader
      @tableHeader.on 'headerItemTap', (headerItem) => @reload()
      @append @tableHeader.el

  _initTable: ->
    @tableView = @_createTable()
    @tableView.datasource = @
    @append @tableView.render().el
    @_subscribeOnScroll()

  _subscribeOnScroll: =>
    scroll = @tableView.el[0]
    jQuery(scroll).on 'scroll', (e) => @_onScroll scroll

  _onScroll: (scroll) =>
    if @_isScrollNearBottom(scroll)
      if @_isHavingMoreFetchedRecords() then @_renderMoreCells() else @_fetchMoreRecords()

  _isScrollNearBottom: (scroll) ->
    scroll.scrollHeight - scroll.scrollTop < 3000

  _isHavingMoreFetchedRecords: ->
    @currentNumberOfRows <= @fetchResponse.records.length

  _renderMoreCells: ->
    @spinner.show()
    setTimeout =>
      @currentNumberOfRows += @cellsBatchSize
      @tableView.refresh()
      @spinner.hide()
      @_androidRefresh() unless Utils.isIOS()
    , 50

  _fetchMoreRecords: =>
    if @fetchResponse.hasMore()
      @spinner.show()
      setTimeout =>
        @collection.getMoreEntitiesFromResponse(@fetchResponse)
        .then (@fetchResponse) =>
          @tableView.refresh()
          @spinner.hide()
          @_androidRefresh() unless Utils.isIOS()
      , 100

  _androidRefresh: =>
    #trick for android 4.2.2
    $('#abbottMobile').height($(window).height())
    setTimeout (=> $('#abbottMobile')[0].style.height = ''), 0

  reset: ->
    @saveSortingHeader()
    @currentNumberOfRows = 100
    @didRender = false
    @fetchResponse = null
    @tableView?.listView.remove()
    @_clearView()

  resetAndActive: (params) ->
    @reset()
    @active params

  _clearView: ->
    @html ''

  filterBy: (@searchString) ->
    @reload()

  reload: ->
    @_renderTableAfterFetching =>
      if @tableHeader?.activeController and not @searchString
        @_sortBy @tableHeader.activeController.fields, @tableHeader.activeController.isAsc
      else if @tableHeader?.activeController and @searchString
        @_filterAndSortBy @searchString, @tableHeader.activeController.fields, @tableHeader.activeController.isAsc
      else if not @tableHeader?.activeController and @searchString
        @_filterBy @searchString
      else
        @_fetchAll()

  _filterBy: (@searchString) =>
    fieldsValues = {}
    for field in @collection.model.searchFields
      fieldsValues[field] = @searchString
    @collection.fetchAllLike fieldsValues

  _filterAndSortBy: (@searchString, fields, isAsc) =>
    fieldsValues = {}
    for field in @collection.model.searchFields
      fieldsValues[field] = @searchString
    @collection.fetchAllLikeAndSortBy fieldsValues, fields, isAsc

  _fetchAll: =>
    @collection.fetchAll()

  _sortBy: (fields, isAsc) =>
    @collection.fetchAllSortedBy fields, isAsc

  _renderTableAfterFetching: (fetchingFn) =>
    @spinner.show()
    setTimeout =>
      fetchingFn()
        .done (@fetchResponse) =>
          @tableView.render()
          @_updateTableHeaderClass()
          @spinner.hide()
          @_androidRefresh() unless Utils.isIOS()
        .fail (err) =>
          @spinner.hide()
          @_androidRefresh() unless Utils.isIOS()
          alert "Error fetching records:\n #{JSON.stringify err}"
    , 100

  _updateTableHeaderClass: =>
    @tableHeader?.el[if @_hasVerticalScrollBar() then 'addClass' else 'removeClass']('content-has-scroll')

  _hasVerticalScrollBar: =>
    if @tableView.el.get(0) then @tableView.el.get(0).scrollHeight > @tableView.el.innerHeight() else false

  cellForRowAtIndexForTable: (index, table) =>
    @datasource.cellForObjectOnTable @fetchResponse.records[index], table

  numberOfRowsForTable: (table) ->
    if @datasource.numberOfRowsForTable?
      @datasource.numberOfRowsForTable table
    else
      if @fetchResponse and @fetchResponse.records.length > 0
        Math.min @currentNumberOfRows, @fetchResponse.records.length

module.exports = LazyTableController
CallReportDataModel = require 'models/clm-call-report-data'

class JSON2KPI
  @parse: (json) ->
    kpi = if json then JSON.parse json else { slides: [] }
    slideField = if kpi.slides then 'slides' else 'slide'
    callReportData = new CallReportDataModel
    callReportData.timeOnPresentation = _.reduce kpi[slideField], ((result, slide) -> result += slide.time), 0
    callReportData.timeOnSlides = callReportData.timeOnPresentation / kpi[slideField].length
    callReportData.timeOnSlides = 0 unless callReportData.timeOnSlides
    callReportData.kpiSrcJson = JSON.stringify kpi
    callReportData

module.exports = JSON2KPI
class KpiHandler

  @getKPIByProduct: (kpiJson, baseKpi, product, displayProduct) =>
    isDisplayingProductWithAlreadyViewedSlides = displayProduct and baseKpi
    json = if (isDisplayingProductWithAlreadyViewedSlides and (product.id is displayProduct.id)) or not isDisplayingProductWithAlreadyViewedSlides then kpiJson else baseKpi
    result = _.extend JSON.parse(JSON.stringify(json)), { slides:[] }
    slideField = if kpiJson.slides then 'slides' else 'slide'
    kpiJson[slideField].forEach (slide) =>
      if @stringContains("P#{product.presentationId}", slide.id) or (displayProduct and (product.id is displayProduct.id))
        slideKpiJson = slide
        slideKpiJson.id = slide.id.replace "P#{product.presentationId}_", ""
        result.slides.push slideKpiJson
    result

  @mergeKPI: (baseKpiJson, updatedKpiJson) =>
    json = _.extend JSON.parse(JSON.stringify(updatedKpiJson)), { slides: baseKpiJson.slides }
    baseKpiJson = JSON.parse(JSON.stringify(json))
    updatedSlides = [];
    updatedKpiJson.slides.forEach (uSlide, uIndex) =>
      baseKpiJson.slides.forEach (bSlide, bIndex) =>
        if @stringContains(bSlide.id, uSlide.id) or @stringContains(uSlide.id, bSlide.id)
          updatedSlides.push uIndex
          baseKpiJson.slides[bIndex].time += (updatedKpiJson.slides[uIndex].time or 0)
          baseKpiJson.slides[bIndex].likes = (updatedKpiJson.slides[uIndex].likes or 0)
          baseKpiJson.slides[bIndex].presentation = updatedKpiJson.slides[uIndex].presentation
    updatedKpiJson.slides.forEach (uSlide, uIndex) =>
      baseKpiJson.slides.push uSlide if updatedSlides.indexOf(uIndex) is -1
    JSON.stringify baseKpiJson

  @stringContains: (str1, str2) =>
    new RegExp(str1).test(str2)

module.exports = KpiHandler
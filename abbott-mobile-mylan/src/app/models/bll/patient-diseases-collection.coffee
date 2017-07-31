EntitiesCollection = require 'models/bll/entities-collection'
PatientDisease = require 'models/patient-disease'
ProfileProductInPortfoliosCollection = require 'models/bll/profile-product-in-portfolios-collection'

class PatientDiseasesCollection extends EntitiesCollection
  model: PatientDisease

  prepareServerConfig: (configPromise) =>
    configPromise.then (config) =>
      profileProductInPortfoliosCollection = new ProfileProductInPortfoliosCollection
      profileProductInPortfoliosCollection.fetchAll()
      .then profileProductInPortfoliosCollection.getAllEntitiesFromResponse
      .then (profileProductInPortfolios) =>
        patientProfileIds = profileProductInPortfolios.map (profileProductInPortfolio) -> "'#{profileProductInPortfolio.patientProfileSfId}'"
        if _.isEmpty(patientProfileIds) then patientProfileIds = null
        config.query += " WHERE #{@model.sfdc.patientProfileSfId} IN (#{patientProfileIds ? 'Null'})"
        config

  fetchByPatientProfileId: (patientProfileId) =>
    keyValue = {}
    keyValue[@model.sfdc.patientProfileSfId] = patientProfileId
    @fetchAllWhere keyValue
    .then @getAllEntitiesFromResponse

module.exports = PatientDiseasesCollection
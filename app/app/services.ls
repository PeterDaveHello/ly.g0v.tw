angular.module 'app.services' []
.factory LYService: <[$http]> ++ ($http) ->
  mly = []
  by-name = {}
  by-id = {}
  do
    init: ->
      <- $http.get '/data/mly-8.json' .success
      mly := it
      for m in mly
        by-name[m.name] = by-id[m.id] = m
    resolveParty: (n) ->
      by-name[n]?party ? 'unknown'
    resolve-party-color: (n) -> {KMT: \#000095 DPP: \#009a00 PFP: \#fe6407}[@resolve-party n] or \#999
    mly-by-name: -> by-name[it]
    parseParty: (n) ->
      party = match n
      | \中國國民黨     => \KMT
      | \國民黨     => \KMT
      | \民主進步黨     => \DPP
      | \民進黨     => \DPP
      | \台灣團結聯盟   => \TSU
      | \台灣團結聯盟   => \TSU
      | \無黨團結聯盟   => \NSU
      | \親民黨         => \PFP
      | \新黨           => \NP
      | \建國黨         => \TIP
      | \超黨派問政聯盟 => \CPU
      | \民主聯盟       => \DU
      | \新國家陣線     => \NNA
      | /無(黨籍)?/     => null
      | \其他           => null
      else => console.error it
      party

.service 'TWLYService': <[LYService]> ++ (LYService) ->
  base = 'http://vote.ly.g0v.tw/voter/'
  getLink: (name) ->
      return if LYService.mly-by-name(name)?id => base + that

.service 'LYModel': <[$q $http $timeout]> ++ ($q, $http, $timeout) ->
    config = require 'config.jsenv'
    base = "#{config.APIENDPOINT}v0/collections/"
    _model = {}

    localGet = (key) ->
      deferred = $q.defer!
      promise = deferred.promise
      promise.success = (fn) ->
        promise.then fn
      promise.error = (fn) ->
        promise.then fn
      $timeout ->
        deferred.resolve _model[key]
      return promise

    wrapHttpGet = (key, url, params) ->
      {success, error}:req = $http.get url, params
      req.success = (fn) ->
        rsp <- success
        _model[key] = rsp
        fn rsp
      req.error = (fn) ->
        rsp <- error
        fn rsp
      return req

    return do
      get: (path, params) ->
        url = base + path
        key = if params => url + JSON.stringify params else url
        key -= /\"/g
        return if _model.hasOwnProperty key
          localGet key
        else
          wrapHttpGet key, url, params

.service 'LYLaws': <[$q $http $timeout]> ++ ($q, $http, $timeout) ->
  config = require 'config.jsenv'
  base = "#{config.APIENDPOINT}v0/collections/laws"
  _laws = []
  init = ->
    {paging, entries} <- $http.get base, do
      params:
        l: -1
    .success
    _laws ++= entries

  search-law = (name) ->
    result = []
    for law in _laws
      if law.name .match name and result.length < 7
        result.push law
    return result

  init!

  return do
    get: (name, cb) ->
      result = search-law name
      cb result

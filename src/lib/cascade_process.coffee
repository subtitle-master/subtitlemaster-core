_        = require("lodash")
W        = require("when")
pipeline = require("when/pipeline")

module.exports = CascadeProcess = (input, filters = []) ->
  filters.unshift(->) if filters.length == 0

  filters = _.map filters, (filter) -> (result) ->
    return false unless result

    W(filter(result)).then (res) -> if res == false then false else result

  pipeline(filters, value: input, info: {})

yaml = require "js-yaml"
fs   = require "fs"

conf-precedence = [
   "/etc/{unitname}/{confname}"
   "~/.config/"
   "~/.{confname}"
   "./"
]

load-or-report-err = (filename) ->
   try
      doc = yaml.safe-load fs.read-file-sync filename, "utf8"
      return doc
   catch e
      return null



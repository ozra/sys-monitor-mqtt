mqtt = require "mqtt"
{exec} = require "child_process"
os = require "os"


now = -> Date.now()

say = (...args) ->
   out = ""
   for arg in args
      out += arg # .to-string
   console.log out

_D = say

pub = (topic, msg, qos = 0, retain = false) ->
   mqttc.publish topic, "" + msg
   return

sub = (topic) ->
   mqttc.subscribe topic


mqtt-port = 1899
check-interval = 5000

total-mem = 0
mqttc = null
checker-tmr = null

MiB = 1024 * 1024.0
GiB = 1024 * 1024 * 1024.0


connect-to-broker = (cb) ->
   mqttc := mqtt.connect "mqtt://localhost:1899"
   mqttc.on "connect", cb
   return

handle-message = (topic, msg) ->
   switch topic
   when "sys/stats-monitor/interval"
      check-interval := parse-int msg
      clear-interval checker-tmr
      start-checking()
      say "updated check-interval to #{check-interval}"
   else
      say "fucked cmd"
   return

init = (cb) ->
   total-mem := os.totalmem() / MiB
   err <- connect-to-broker
   sub "sys/stats-monitor/interval"
   mqttc.on "message", handle-message 
   return cb()

check = ->
   ram = os.freemem() / MiB
   one-five-and-fifteen = os.loadavg()
   ram-perc = (total-mem - ram) / total-mem
   uptime = Math.round(os.uptime() / 60 / 60, 2)

   cmd = "df -h"
   exec cmd, (c, o, e) ->
      # say "std: #{o}\nerr: #{e}\ncode: #{c}\n"
      cut-up = o.split("\n").map (s) -> s.split(/\s+/)
      dfree = cut-up.8.3.replace /G$/, ""
      # say "disk free: #{dfree}"
      
      pub "sys/dfree", dfree
      return

   pub "sys/free", Math.round ram, 2
   pub "sys/cpu(1m)", Math.round(one-five-and-fifteen.0 * 100, 0)
   pub "sys/uptime", uptime 
   return

start-checking = ->
   checker-tmr := set-interval check, check-interval
   return

main = ->
   say "kicking off!"

   <- init
   start-checking()
   return

main()


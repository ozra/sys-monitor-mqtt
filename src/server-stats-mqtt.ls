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

pub-via-exec = (topic, msg, qos = 0, retain = false) ->
   cmd = "mosquitto_pub -p #{mqtt-port} -t \"#{topix}\" -m \"#{msg}\""
   exec cmd
   return

pub-via-mod = (topic, msg, qos = 0, retain = false) ->
   mqttc.publish topic, msg
   return

pub = pub-via-mod

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
   when "vps/stats-monitor/interval"
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
   sub "vps/stats-monitor/interval"
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
      
      cmd = "mosquitto_pub -p #{mqtt-port} -t \"dfree\" -m \"#{dfree}\""
      exec cmd
      return

   # say "data for pub: ", ram, ", ", total-mem, " (", ram-perc, ") ", one-five-and-fifteen.join " - "

   cmd = "mosquitto_pub -p #{mqtt-port} -t \"free\" -m \"#{Math.round(ram, 2)}\""
   exec cmd

   cmd = "mosquitto_pub -p #{mqtt-port} -t \"load(1m)\" -m \"#{Math.round(one-five-and-fifteen.0 * 100, 0)}\""
   exec cmd

   cmd = "mosquitto_pub -p #{mqtt-port} -t \"uptime\" -m \"#{uptime}\""
   exec cmd
   
   mqttc.publish "vps/foo", "Testing yaaau!"

   return

start-checking = ->
   checker-tmr := set-interval check, check-interval

main = ->
   say "do stuff"

   <- init
   start-checking()

main()


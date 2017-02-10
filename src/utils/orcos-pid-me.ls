
PID-PATH = "/var/run/"

*TODO* lock the file to avoid race conditions?

#| do-pid-stuff(pid-name: Str, policy: Str = "replace")
#| @pid-name = the name of your app / the pid-file
#| @policy = "exit-always" | "exit-if-running" | "replace"
exports.
pid-me = (pid-name, policy = "replace") ->
   pid-name? || throw new Error "you need to pass a pid-name (your apps name)"

   filename = "#{PID-PATH}#{pid-name}"
   try
      existing-pid = fs.read-file-sync filename

      switch policy
      when "replace"
         process.kill existing-pid
      when "exit-always"
         process.exit 1
      when "exit-if-running"
         # *TODO* check if pid is up and running
      else
         throw new Error "Unknown pid-policy: \"#{policy}\""


   catch err
      # *TODO* ensure it depends on file not existing
      existing-pid = ""

   try
      fs.write-file-sync filename, process.pid.to-string()
   catch err
      # *TODO* access permissions error? etc

   return


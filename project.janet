(declare-project
  :name "weather-joy"
  :description ""
  :dependencies ["https://github.com/joy-framework/joy"
                 "https://github.com/joy-framework/http"
                 "https://github.com/janet-lang/sqlite3"
                 "spork"]
  :author ""
  :license ""
  :url ""
  :repo "")

# execute with `jpm run server` in the shell
(phony "server" []
       (os/shell "janet server.janet"))

# execute with `jpm run format` in the shell
(phony "format" []
       (os/shell "janet fmt.janet *.janet"))

(declare-executable
  :name "app"
  :entry "server.janet")

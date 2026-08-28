(declare-project
  :name "weather-joy"
  :description ""
  :dependencies ["https://github.com/joy-framework/joy"
                 "https://github.com/janet-lang/sqlite3"
                 "https://github.com/joy-framework/http"]
  :author ""
  :license ""
  :url ""
  :repo "")

# execute with `jpm run server` in the terminal
(phony "server" []
       (os/shell "janet main.janet"))

(phony "format" []
       (os/shell "janet fmt.janet *.janet project.janet"))

(declare-executable
  :name "app"
  :entry "main.janet")

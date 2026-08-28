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

(phony "server" []
  (os/shell "janet main.janet"))

(declare-executable
  :name "app"
  :entry "main.janet")

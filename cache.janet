(import spork/json)

(defn json-file-write [path data]
  (let [fh (file/open path :w)
        json (json/encode data)
        _ (print "json-file-write " path " " json)
        _ (file/write fh json)
        _ (file/close fh)]
    true))

(defn json-file-read [path]
  (let [fh (file/open path :r)
        raw (file/read fh :all)
        _ (file/close fh)
        _ (print "json-file-read " path "\n" raw)
        data (json/decode raw true true)]
    data))

(defn cache-envelope [date expire-seconds]
  (let [save-date (date/utc-now)
        expire-date (date/add save-date :seconds expire-seconds)]
    {:save-date save-date :expire-date expire-date :data data}))

(defn still-valid? [envelope]
  (let [now (date/utc-now)
        past (envelope :save-date)
        expire (envelope :expire-date)
        is-valid (date/is-between? now past expire)]
    is-valid))

(defn cache-key-to-path [key]
  (string "./cache/c" (hash key) ".json"))

(defn load-cache [key]
  (let [path (cache-key-to-path)
        raw-json (json-file-read path)
        date-valid (still-valid? raw-json)]
    (if date-valid (raw-json :data) false)))

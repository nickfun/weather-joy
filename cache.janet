(import spork/json)
(import spork/date)

# what

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

(defn cache-envelope [ttl data]
  (let [save-date (date/utc-now)
        expire-date (date/add save-date :seconds ttl)]
    {:save-date save-date :expire-date expire-date :data data}))

(defn still-valid? [envelope]
  (let [now (date/utc-now)
        past (table/to-struct (envelope :save-date))
        expire (table/to-struct (envelope :expire-date))
        _ (print "testing date/between " now " " past " " expire)
        is-valid (date/between? now past expire)]
    is-valid))

(defn cache-key-to-path [key]
  (string "./cache/c" (hash key) ".json"))

(defn load-cache [key]
  (def [load-result data]
    (protect
      (let [path (cache-key-to-path key)
            raw-json (json-file-read path)
            date-valid (still-valid? raw-json)
            _ (print "date valid? " date-valid)]
        (if date-valid (raw-json :data) false))))
  (if load-result
    data
    false))

(defn write-cache [key ttl data]
  (def [write-result data]
    (protect
      (let [payload (cache-envelope ttl data)
            path (cache-key-to-path key)]
        (json-file-write path payload)
        true)))
  write-result)

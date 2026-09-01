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

(defn cache-key-to-path [key]
  (string "./cache/c" (hash key) ".json"))

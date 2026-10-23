(import spork/date)

(defn jdn-file-write [path data]
  (let [fh (file/open path :w)
        raw-jdn (string/format "%j" data)
        # _ (print "jdn-file-write " path " " raw-jdn)
        _ (file/write fh raw-jdn)
        _ (file/close fh)]
    true))

(defn jdn-file-read [path]
  (let [fh (file/open path :r)
        raw (file/read fh :all)
        _ (file/close fh)
        # _ (print "cache: jdn-file-read " path "\n" raw)
        data (parse raw)]
    data))

(defn cache-envelope [ttl data key]
  (let [save-date (date/utc-now)
        expire-date (date/add save-date :seconds ttl)]
    {:key key :save-date save-date :expire-date expire-date :data data}))

(defn still-valid? [envelope]
  #  (print "cache: still-valid? " (string/format "%j" envelope))
  (let [now (date/utc-now)
        past (envelope :save-date)
        expire (envelope :expire-date)
        #        _ (print "testing date/between " now " " past " " expire)
        is-valid (date/between? now past expire)
        #        _ (print "is valid result " (string/format "%j" is-valid))
        ]
    is-valid))

(defn cache-key-to-path [key]
  (string "./__cached/c" (hash key) ".jdn"))

(defn load-cache [key]
  (def [load-result data]
    (protect
      (let [path (cache-key-to-path key)
            #            _ (print "cache load path is " path)
            cached-data (jdn-file-read path)
            #            _ (print "cache load data is " cached-data)
            date-valid (still-valid? cached-data)
            #            _ (print "cache " key " date valid? " date-valid)
            ]
        (if date-valid (cached-data :data) false))))
  (if load-result
    data
    false))

(defn write-cache [key ttl data]
  (def [write-result data]
    (protect
      (let [payload (cache-envelope ttl data key)
            path (cache-key-to-path key)]
        (jdn-file-write path payload)
        true)))
  write-result)

(defn cache
  ``
  key: Your cache key
  ttl: how many seconds this should be cached for
  userfn: a function to run to fill the cache

  The main interface to the little cache library. Runs your function and caches
  it and doesn't run it again until the cache expires.
  ``
  [key ttl userfn]
  (def load-result (load-cache key))
  (if (= false load-result)
    (do
      #      (print "cache miss! " key)
      (def user-data (userfn))
      (def write-result (write-cache key ttl user-data))
      user-data)
    (do
      #      (print "cache hit! " key)
      load-result)))

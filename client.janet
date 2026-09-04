(import http)
(import spork/json)
(import ./cache)

(def DAYS_7 (* 60 60 24 7))
(def MINUTES_5 (* 60 5))

# base client
(defn get-json
  "Make a GET request and parse the result as JSON"
  [url query-params]
  (print "DOWNSTREAM: " url " " (string/format "%m" query-params))
  (let [params-str (http/form-encode query-params)
        params-str (if (pos? (length params-str)) (string "?" params-str) "")
        params-str (string/replace-all " " "%20" params-str)
        full-url (string url params-str)
        response (http/get full-url)
        # _ (print "Debug URL: " full-url)
        # _ (print "Full Respose: " (response :body))
        json-response (json/decode (response :body))]
    (put response :json json-response)
    response))

(defn address-to-coords [address]
  (let [benchmark "Public_AR_Current"
        format "json"
        query-params {:address address :benchmark benchmark :format format}
        url "https://geocoding.geo.census.gov/geocoder/locations/onelineaddress"
        result (get-json url query-params)
        lat (get-in result [:json "result" "addressMatches" 0 "coordinates" "x"])
        lon (get-in result [:json "result" "addressMatches" 0 "coordinates" "y"])]
    {:lat lat :lon lon}))

(defn coords-to-next-links [coords]
  (print "debug: coords: ")
  (pp coords)
  (let [str-lat (string/slice (string (coords :lat)) 0 7)
        str-lon (string/slice (string (coords :lon)) 0 7)
        url-tpl "https://api.weather.gov/points/%s,%s"
        url (string/format url-tpl str-lon str-lat)
        #_ (print "weather url: " url)
        result (get-json url {})
        base-forecast (get-in result [:json "properties" "forecast"])
        hourly-forecast (get-in result [:json "properties" "forecastHourly"])
        answer {:url-forecast base-forecast :url-forecast-hourly hourly-forecast}]
    #(print "Weather Next URLS:")
    answer))

(defn links-to-forecast [links]
  (let [forecast-url (links :url-forecast)
        results (get-json forecast-url [])
        # _ (print "raw results of forecast ")
        # _ (pp results)
        periods (get-in results [:json "properties" "periods"])]
    periods))

(defn address-to-weather [address]
  (def cache-key-links (string "links:" address))
  (def cache-key-forecast (string "weather:" address))
  (def next-links
    (cache/cache cache-key-links DAYS_7
                 (fn []
                   (def corrds (address-to-coords address))
                   (coords-to-next-links corrds))))
  (def forecast
    (cache/cache cache-key-forecast MINUTES_5
                 (fn []
                   (links-to-forecast next-links))))
  {:forecast forecast})

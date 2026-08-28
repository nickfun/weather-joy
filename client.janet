(import http)
(import spork/json)

# client
(defn get-json
  "Make a GET request and parse the result as JSON"
  [url query-params]
  (let [params-str (http/form-encode query-params)
        params-str (if (pos? (length params-str)) (string "?" params-str) "")
        params-str (string/replace-all " " "%20" params-str)
        full-url (string url params-str)
        response (http/get full-url)
        #_ (print "Debug URL: " full-url)
        #_ (print "Full Respose: " (response :body))
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

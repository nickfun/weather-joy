(use joy)
(import http)
(import ./client)

# Views
# =====

(defn view-forecast-period [period]
  (print "invoke view-forecast-period")
  (pp period)
  (let [day (period "name")
        _temp (period "temperature")
        _unit (period "temperatureUnit")
        temp (string _temp " " _unit)
        detail (period "detailedForecast")]
    [:div
     [:h4 day]
     [:div temp]
     [:div detail]]))

# Layout
# ======

(defn app-layout [{:body body :request request}]
  (text/html
    (doctype :html5)
    [:html {:lang "en"}
     [:head
      [:title "weather-joy"]
      [:meta {:charset "utf-8"}]
      [:meta {:name "viewport" :content "width=device-width, initial-scale=1"}]
      [:meta {:name "csrf-token" :content (csrf-token-value request)}]
      [:link {:href "/app.css" :rel "stylesheet"}]
      [:script {:src "/app.js" :defer ""}]]
     [:body
      [:main
       body]
      [:footer
       [:span "Powered by Janet"]]]]))


# Routes
# ======

(route :get "/" :home)
(defn home [request]
  [:div {:class "tc"}
   [:h1 "You found joy!"]
   [:p {:class "code"}
    [:b "Joy Version:"]
    [:span (string " " version)]]
   [:p "Hey I am new! and that is great"]
   [:p {:class "code"}
    [:b "Janet Version:"]
    [:span janet/version]]
   [:form {:method "get" :action "/weather"}
    [:input {:type "text" :name "address"}]
    [:input {:type "submit"}]]])

(route :get "/weather" :get-weather)
(defn get-weather [request]
  (let [qs (request :query-string)
        address (qs :address)
        weather (client/address-to-weather address)
        forecast (weather :forecast)
        forecast-periods (get-in forecast ["properties" "periods"])
        _ (print "weater is")
        _ (print (string/format "%m" weather))
        _ (print "forecast-periods is")
        _ (print (string/format "%m" forecast-periods))]
    (pp (request :query-string))
    (pp address)
    [:div
     [:div "check the output!"]
     [:h3 {} address]
     (map view-forecast-period forecast-periods)]))

# Middleware
(def app (-> (handler)
             (layout app-layout)
             (with-csrf-token)
             (with-session)
             (extra-methods)
             (query-string)
             (body-parser)
             (json-body-parser)
             (server-error)
             (x-headers)
             (static-files)
             (not-found)
             (logger)))


# Server
(defn main [& args]
  (let [port (get args 1 (os/getenv "PORT" "9001"))
        host (get args 2 "0.0.0.0")]
    (print (string "Server will bind to host and port " host " " port))
    (server app port host)))

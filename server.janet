(use joy)
(import ./client)

# Views
# =====

(defn view-forecast-period [period]
  # (print "invoke view-forecast-period")
  # (pp period)
  (let [day (period :name)
        _temp (period :temperature)
        _unit (period :temperatureUnit)
        temp (string _temp " " _unit)
        detail (period :detailedForecast)
        result [:div
                [:h4 day]
                [:div temp]
                [:div detail]]]
    result))

# Layout
# ======

(defn my-hiccup-layout [body request]
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
    [:footer.bottom
     [:a {:href "/"} "Home"]
     [:span {} " | "]
     [:a {:href "/about"} "About"]
     [:span {} " | "]
     [:span "Powered by Janet with Joy"]]]])

(defn app-layout [{:body body :request request}]
  (text/html
    (doctype :html5)
    (my-hiccup-layout body request)))


# Routes
# ====== 

(route :get "/" :home)
(defn home [request]
  [:div {:class "tc"}
   [:h1 "Simple Weather Report"]
   [:p "Enter a USA Address below and I'll use the National Weather Service to get a weather report."]
   [:form {:method "get" :action "/weather"}
    [:input {:type "text" :name "address"}]
    [:input {:type "submit"}]]])

(route :get "/weather" :get-weather)
(defn get-weather [request]
  (let [qs (request :query-string)
        address (qs :address)
        clean-address (string/replace-all "+" " " address)
        [load-result weather-data] (protect (client/address-to-weather address))]

    (if load-result
      (do
        (def forecast (weather-data :forecast))
        (pp (request :query-string))
        (pp address)
        (def existing (in request :session []))
        (def ses (array/push existing address))
        (def body [:div
                   [:h1 "Weather Report"]
                   [:h2 clean-address]
                   (map view-forecast-period forecast)])
        @{:status 200
          :body (html (my-hiccup-layout body request))
          :session ses
          :headers @{"Content-Type" "text/html"}})
      (do
        # fail state!
        (pp {:message "Failed to load weather data!" :error-msg weather-data :address address})
        [:div
         [:h1 "Error!"]
         [:p "Sorry, could not get weather data for your input."]
         [:p address]]))))

(route :get "/about" :about)
(defn about [request]
  [:div {:class "tc"}
   [:h1 "You found joy!"]
   [:p {:class "code"}
    [:b "Joy Version:"]
    [:span (string " " version)]]
   [:p {:class "code"}
    [:b "Janet Version:"]
    [:span janet/version]]])

(route :get "/session" :debug-session)
(defn debug-session [request]
  (def my-address "15966 selborne dr")
  (def existing (in request :session []))
  (def ses (array ;existing))
  (array/push ses my-address)
  (array/push ses "100")
  (pp ses)
  @{:status 200
    :body (html (my-hiccup-layout [:h1 "Session Debug"] request))
    :headers @{"Content-Type" "text/html"}
    :session []})

(route :get "/debug-cookie" :debug-cookie)
(defn debug-cookie [request]
  (pp (get-in request [:headers "Cookie"]))
  (let [my-body [:h1 "Hi nice to see you!"]
        body (html my-body)]
    @{:status 200
      :body body
      :headers @{"X-First" "first custom"
                 "Set-Cookie" @[(http/cookie-string "key_1" "value one!" @{})
                                (http/cookie-string "key_2" "value two!" @{})]
                 "Content-Type" "text/html"}}))


# Middleware
(def app (-> (handler)
             (layout app-layout)
             (with-csrf-token)
             (with-session {"Max-Age" "2592000"})
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

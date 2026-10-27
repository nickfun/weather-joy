(import "spork/httpf")

(def my-server (httpf/server))

(defn my-debug-route
  {:path "/debug"
   :render-mime "text/html"
   :route-doc "this is the debug route, it has debug code and data."}
  "i am function doc for my-debug-route it is here"
  [request post-data]
  (def items [:body :data])
  (def reqdata @{})
  (each i items
    (put reqdata i (request i)))
  (printf "The keys of REQUEST param:\n%j" (keys request))
  (printf "----")
  (printf "POST DATA:")
  (printf "%j" post-data)
  (printf "REQDATA:\n%j" reqdata)
  [:h1 "I return this data!"])

(defn my-index-route
  {:path "/"
   :render-mime "text/html"
   :doc "root of the server"}
  "a simple index!"
  [request post-data]
  (def body [:body [:h1 "Welcome to httpf"]
             [:p "I am glad you are here!"]])
  (setdyn :response-code 201)
  (setdyn :response-haders @{:my-extra "hell yes extra!"})
  body)

(httpf/add-bindings-as-routes my-server)

(httpf/listen my-server "localhost" "8009" 3)

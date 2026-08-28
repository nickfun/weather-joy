(import "./client")

(let [address "3239 Lenard Dr, Castro Valley, CA, 94546"
      result (client/address-to-coords address)]
    (print "Address: " address "\nLat: " (result :lat) "\nLon: " (result :lon)))
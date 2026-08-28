(import "./client")

(def address-list [
    "3239 lenard dr, castro valley, ca, 94546"
    "19663 Alvertus Ave, Castro Valley, CA, 94546"
    "15966 Selborne Dr, San leandro, CA, 94578"])

(defn mappr [addr] (print "Address: " addr) (pp (client/address-to-coords addr)))

(map mappr address-list)
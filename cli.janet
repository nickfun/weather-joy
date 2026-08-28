(import "./client")

(def address-list ["4512 N Sunnyside Ave, Fresno, CA 93727"
                   "3239 lenard dr, castro valley, ca, 94546"
                   "19663 Alvertus Ave, Castro Valley, CA, 94546"
                   "15966 Selborne Dr, San leandro, CA, 94578"])

(defn mappr [addr] (print "Address: " addr) (pp (client/address-to-coords addr)))

(let [input (address-list 0)
      coords (client/address-to-coords input)
      next-links (client/coords-to-next-links coords)]
  (print "Client Done"))

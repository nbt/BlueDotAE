ClientSetup.setup("Chris Wright", "1402 EOLUS AVE, ENCINITAS, CA 92024", "ChrisWrightFamily", "U0RHRW9sdXMxNDAy", ["01046957", "05219047"])
ClientSetup.setup("Dean McDaniel", "4477 ROBBINS ST, SAN DIEGO, CA 92122", "dmcdaniel", "ZGJtZGJt", ["00634906", "05475407"])
ClientSetup.setup("Donna Peterson", "8022 LINDA VISTA RD 1H, SAN DIEGO, CA 92111", "dpeterson1", "d2hpc2tlcnM1NA==", ["05920469"])
ClientSetup.setup("Fabio Soto", "2335 CANYON RD, ESCONDIDO, CA 92025", "fabio.soto", "Ymx1ZTdib3ds", ["00921281", "05454879"])
ClientSetup.setup("Greg Fisch", "11760 CARMEL CREEK RD 105, SAN DIEGO, CA 92130", "gfisch", "Z3pmZ3pmMTIz", ["00777028", "05448565"])
ClientSetup.setup("Joe Demkowski", "7495 MURIEL PL, LA MESA, CA 91941", "joe7495", "am9lc2tpMTk2NA==", ["01175708", "05733674"])

# Find local weather stations
Premises.nightly_task

# Find utility bills
ServiceAccount.nightly_task

# Find weather observations concurent with the utility bills
WeatherStation.nightly_task


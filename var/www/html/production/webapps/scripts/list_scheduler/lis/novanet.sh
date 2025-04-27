#!/bin/sh

###############################################################
# Kirim Order Lab Dan Ambil Hasil Lab di Server perantara LIS #
###############################################################
curl -sS http://localhost/webservice/lis/service/run?driverName=LISService\\novanet\\dbservice\\Driver > /dev/null
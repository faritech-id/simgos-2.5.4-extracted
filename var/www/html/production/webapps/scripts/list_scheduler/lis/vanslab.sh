#!/bin/sh

###############################################################
# Kirim Order Lab Dan Ambil Hasil Lab di Server perantara LIS #
###############################################################
curl -sS http://localhost/webservice/lis/service/run?driverName=LISService\\vanslab\\dbservice\\Driver > /dev/null
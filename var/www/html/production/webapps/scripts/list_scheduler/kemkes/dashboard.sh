#!/bin/sh

########################
# Kirim data Dashboard #
########################

# 1. Kunjungan
curl -sS http://localhost/webservice/kemkes/run/kunjungan > /dev/null

# 2. Indikator
curl -sS http://localhost/webservice/kemkes/run/indikator > /dev/null

# 3. Kematian
curl -sS http://localhost/webservice/kemkes/run/kematian > /dev/null

# 4. Rujukan
curl -sS http://localhost/webservice/kemkes/run/rujukan > /dev/null

# 5. 10 Besar Penyakit
curl -sS http://localhost/webservice/kemkes/run/penyakit10Besar > /dev/null

# 6. 10 Besar Penyakit Rujukan
curl -sS http://localhost/webservice/kemkes/run/diagnosaRujukan10Besar > /dev/null
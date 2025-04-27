#!/bin/sh

########################
# Kirim data IHS #
########################

# 1. organization
curl -sS http://localhost/webservice/kemkes/ihs/organization/send > /dev/null

# 2. location
curl -sS http://localhost/webservice/kemkes/ihs/location/send > /dev/null

# 3. patient
curl -sS http://localhost/webservice/kemkes/ihs/patient/getIhs > /dev/null

# 4. practitioner
curl -sS http://localhost/webservice/kemkes/ihs/practisioner/getIhs > /dev/null

# 5. encounter
curl -sS http://localhost/webservice/kemkes/ihs/encounter/send > /dev/null

# 6. condition
curl -sS http://localhost/webservice/kemkes/ihs/condition/send > /dev/null

# 7. observation
curl -sS http://localhost/webservice/kemkes/ihs/observation/send > /dev/null

# 8. composition
curl -sS http://localhost/webservice/kemkes/ihs/composition/send > /dev/null

# 9. medication
curl -sS http://localhost/webservice/kemkes/ihs/medication/send > /dev/null

# 10. medication request
curl -sS http://localhost/webservice/kemkes/ihs/medication/request/send > /dev/null

# 11. medication dispense
curl -sS http://localhost/webservice/kemkes/ihs/medication/dispanse/send > /dev/null

# 12. procedure
curl -sS http://localhost/webservice/kemkes/ihs/procedure/send > /dev/null

# 13. Service Request
curl -sS http://localhost/webservice/kemkes/ihs/servicerequest/send > /dev/null

# 14. Speciment
curl -sS http://localhost/webservice/kemkes/ihs/specimen/send > /dev/null

# 15. Diagnostic Report
curl -sS http://localhost/webservice/kemkes/ihs/diagnosticreport/send > /dev/null

# 16. Consent
curl -sS http://localhost/webservice/kemkes/ihs/consent/send > /dev/null

USE `kemkes-ihs`;

REPLACE INTO `code_reference` (`id`, `resources`, `entity`, `system`, `status`) VALUES (60, 'AllergyIntolerance', 'identifier', 'http://sys-ids.kemkes.go.id/allergy', 1);
REPLACE INTO `code_reference` (`id`, `resources`, `entity`, `system`, `status`) VALUES (61, 'AllergyIntolerance', 'clinicalStatus', 'http://terminology.hl7.org/CodeSystem/allergyintolerance-clinical', 1);
REPLACE INTO `code_reference` (`id`, `resources`, `entity`, `system`, `status`) VALUES (62, 'AllergyIntolerance', 'verificationStatus', 'http://terminology.hl7.org/CodeSystem/allergyintolerance-verification', 1);
REPLACE INTO `code_reference` (`id`, `resources`, `entity`, `system`, `status`) VALUES (63, 'AllergyIntolerance', 'category', '', 1);

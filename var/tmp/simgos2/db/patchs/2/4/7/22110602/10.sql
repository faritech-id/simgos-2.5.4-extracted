USE `kemkes-ihs`;

REPLACE INTO `code_reference` (`id`, `resources`, `entity`, `system`, `status`) VALUES (13, 'Medication', 'identifier', 'https://sys-ids.kemkes.go.id/medication', 1);
REPLACE INTO `code_reference` (`id`, `resources`, `entity`, `system`, `status`) VALUES (14, 'Medication', 'code', 'http://sys-ids.kemkes.go.id/kfa', 1);
REPLACE INTO `code_reference` (`id`, `resources`, `entity`, `system`, `status`) VALUES (15, 'Medication', 'form', 'https://terminology.kemkes.go.id/CodeSystem/medication-form', 1);
REPLACE INTO `code_reference` (`id`, `resources`, `entity`, `system`, `status`) VALUES (16, 'Medication', 'extension', 'https://fhir.kemkes.go.id/r4/StructureDefinition/MedicationType', 1);
REPLACE INTO `code_reference` (`id`, `resources`, `entity`, `system`, `status`) VALUES (17, 'Medication', 'extension.valueCodeableConcept', 'https://terminology.kemkes.go.id/CodeSystem/medication-type', 1);
REPLACE INTO `code_reference` (`id`, `resources`, `entity`, `system`, `status`) VALUES (18, 'Medication', 'status', '', 1);
REPLACE INTO `code_reference` (`id`, `resources`, `entity`, `system`, `status`) VALUES (19, 'Medication', 'ingredient.strength', '', 1);
REPLACE INTO `code_reference` (`id`, `resources`, `entity`, `system`, `status`) VALUES (20, 'Medication', 'ingredient.itemCodeableConcept', 'http://sys-ids.kemkes.go.id/kfa', 1);
REPLACE INTO `code_reference` (`id`, `resources`, `entity`, `system`, `status`) VALUES (21, 'MedicationRequest', 'status', '', 1);
REPLACE INTO `code_reference` (`id`, `resources`, `entity`, `system`, `status`) VALUES (22, 'MedicationRequest', 'intent', '', 1);
REPLACE INTO `code_reference` (`id`, `resources`, `entity`, `system`, `status`) VALUES (23, 'MedicationRequest', 'statusReason', 'https://hl7.org/FHIR/codesystem-medicationrequest-status-reason.html', 1);
REPLACE INTO `code_reference` (`id`, `resources`, `entity`, `system`, `status`) VALUES (24, 'MedicationRequest', 'category', 'https://hl7.org/fhir/R4/codesystem-medicationrequest-category.html', 1);
REPLACE INTO `code_reference` (`id`, `resources`, `entity`, `system`, `status`) VALUES (25, 'MedicationRequest', 'priority', '', 1);
REPLACE INTO `code_reference` (`id`, `resources`, `entity`, `system`, `status`) VALUES (26, 'MedicationRequest', 'identifier', 'http://sys-ids.kemkes.go.id/prescription', 1);
REPLACE INTO `code_reference` (`id`, `resources`, `entity`, `system`, `status`) VALUES (27, 'MedicationRequest', 'identifier.item', 'http://sys-ids.kemkes.go.id/prescription-item', 1);
REPLACE INTO `code_reference` (`id`, `resources`, `entity`, `system`, `status`) VALUES (28, 'MedicationRequest', 'dosageInstruction.sequence', '', 1);
REPLACE INTO `code_reference` (`id`, `resources`, `entity`, `system`, `status`) VALUES (29, 'MedicationRequest', 'dosageInstruction.route', 'http://www.whocc.no/atc', 1);
REPLACE INTO `code_reference` (`id`, `resources`, `entity`, `system`, `status`) VALUES (30, 'MedicationRequest', 'dosageInstruction.doseAndRate', 'http://terminology.hl7.org/CodeSystem/dose-rate-type', 1);
REPLACE INTO `code_reference` (`id`, `resources`, `entity`, `system`, `status`) VALUES (31, 'MedicationDispense', 'identifier', 'http://sys-ids.kemkes.go.id/prescription', 1);
REPLACE INTO `code_reference` (`id`, `resources`, `entity`, `system`, `status`) VALUES (32, 'MedicationDispense', 'identifier.item', 'http://sys-ids.kemkes.go.id/prescription-item', 1);
REPLACE INTO `code_reference` (`id`, `resources`, `entity`, `system`, `status`) VALUES (33, 'MedicationDispense', 'status', '', 1);
REPLACE INTO `code_reference` (`id`, `resources`, `entity`, `system`, `status`) VALUES (34, 'MedicationDispanse', 'category', 'http://terminology.hl7.org/fhir/CodeSystem/medicationdispense-category', 1);

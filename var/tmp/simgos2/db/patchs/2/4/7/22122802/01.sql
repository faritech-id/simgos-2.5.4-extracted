USE `kemkes-ihs`;
ALTER TABLE observation
	ADD COLUMN identifier JSON NULL DEFAULT NULL AFTER id;
    

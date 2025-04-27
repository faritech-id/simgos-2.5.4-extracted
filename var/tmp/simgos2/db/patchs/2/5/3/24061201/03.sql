-- Dumping database structure for master
USE `master`;

-- Dumping structure for function master.remove_html_tags
DROP FUNCTION IF EXISTS `remove_html_tags`;
DELIMITER //
CREATE FUNCTION `remove_html_tags`(
	`input` TEXT
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
  DECLARE output TEXT;
  SET output = input;

  -- Hapus semua tag HTML
  WHILE LOCATE('<', output) > 0 DO
    SET output = CONCAT(SUBSTRING(output, 1, LOCATE('<', output) - 1), SUBSTRING(output, LOCATE('>', output) + 1));
  END WHILE;

  -- Hapus karakter HTML yang tersisa
  SET output = REPLACE(output, '&nbsp;', ' ');
  SET output = REPLACE(output, '&quot;', '"');
  SET output = REPLACE(output, '&lt;', '<');
  SET output = REPLACE(output, '&gt;', '>');
  SET output = REPLACE(output, '&amp;', '&');

  RETURN output;
END//
DELIMITER ;

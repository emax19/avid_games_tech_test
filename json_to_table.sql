DELIMITER //

CREATE OR REPLACE PROCEDURE json_to_table(json_input text)
BEGIN
     IF JSON_TYPE(json_input) != 'OBJECT' OR JSON_TYPE(json_input) IS NULL THEN
        SIGNAL SQLSTATE '45000' SET
        MYSQL_ERRNO = 333,
        MESSAGE_TEXT = 'Invalid JSON object';
    END IF;

   -- analogue of the unnest function(expand an array(json keys) to a set of rows)
	WITH RECURSIVE `cte` (`n`, `key`) AS (
      SELECT 0 as `n`,
             json_value(json_keys(json_input), '$[0]') as `key`
       UNION ALL
      SELECT `n` + 1 as `n`,
             json_value(json_keys(json_input), concat('$[',`n`,']'))
        FROM `cte` WHERE `n` < json_length(json_input) - 1
    )
    SELECT `key`,
            json_unquote(json_extract(json_input, concat('$.',`key`))) as `value`
    FROM `cte`
   WHERE `key` IS NOT NULL; -- in case with empty object I want to avoid an empty(null) record

END//

DELIMITER ;

DROP PROCEDURE IF EXISTS generateUsername;
DELIMITER $$

CREATE PROCEDURE generateUsername(
									IN  p_first_name  VARCHAR(100),
									IN  p_last_name   VARCHAR(100),
									OUT p_username    VARCHAR(150)
								)
BEGIN

    DECLARE v_base_username 	VARCHAR(150);
    DECLARE v_candidate     	VARCHAR(150);
    DECLARE v_exists        	INT DEFAULT 1;
    DECLARE v_random_num    	INT;
    DECLARE v_attempts      	INT DEFAULT 0;

    -- Normalize name (lowercase + remove spaces)
    SET v_base_username = LOWER(REPLACE(CONCAT(p_first_name, p_last_name), ' ', ''));

    -- Try max 15 times to avoid infinite loop
    WHILE v_exists > 0 AND v_attempts < 15 DO

        -- Generate random 4-digit number (1000–9999)
        SET v_random_num = FLOOR(1000 + (RAND() * 9000));

        SET v_candidate = CONCAT(v_base_username, v_random_num);

        SELECT COUNT(*)
        INTO v_exists
        FROM customer
        WHERE username = v_candidate;

        SET v_attempts = v_attempts + 1;

    END WHILE;

    SET p_username = v_candidate;

END $$

DELIMITER ;

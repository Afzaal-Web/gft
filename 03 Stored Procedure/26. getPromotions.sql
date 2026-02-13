-- ==================================================================================================
-- Procedure:   getPromotions
-- Purpose:     Retrieve active promotions for a specific user
-- ==================================================================================================

DROP PROCEDURE IF EXISTS getPromotions;
DELIMITER $$

CREATE PROCEDURE getPromotions (
								IN  pReqObj JSON,
								OUT pResObj JSON
							)
BEGIN
    DECLARE  v_loginId    	 VARCHAR(100);
    DECLARE  v_promotions  	JSON;

    main_block: BEGIN

        -- Extract loginId from request
        SET v_loginId 		= getJval(pReqObj, 'P_LOGIN_ID');

        -- Fetch promotions JSON array for this user
        SELECT 		promotion_json
        INTO 		v_promotions
        FROM 		promotions
        WHERE 		status = 'active';

        -- If no promotions found, return empty array
        IF v_promotions IS NULL THEN
            SET v_promotions = JSON_ARRAY();
        END IF;

        -- Build response
        SET pResObj = JSON_OBJECT(
            'status', 'success',
            'message', CONCAT('Promotions retrieved for user ', v_loginId),
            'promotions', v_promotions
        );

    END main_block;
END $$

DELIMITER ;

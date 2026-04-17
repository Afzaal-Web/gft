-- ==================================================================================================
-- Procedure:   getPromotions
-- Purpose:     Retrieve active promotions for a specific user
-- ==================================================================================================

DROP PROCEDURE IF EXISTS getPromotions;
DELIMITER $$

CREATE PROCEDURE getPromotions (
								IN      pjReqObj JSON,
								INOUT  pjRespObj JSON
							)
BEGIN
    

    DECLARE  v_promotions  	JSON;

    main_block: BEGIN


        -- Fetch promotions JSON array for this user
        SELECT 		JSON_ARRAYAGG(promotion_json)
        INTO 		v_promotions
        FROM 		promotions
        WHERE 		status = 'active';

        -- If no promotions found, return empty array
        IF v_promotions IS NULL THEN
           
            SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.responseCode', 1);
            SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.message', 'No promotions found ');
            LEAVE main_block;
        END IF;

        -- Build response
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode',   0);
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',       'Promotions retrieved for user ');
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jData.contents',         v_promotions);

    END main_block;
END $$

DELIMITER ;


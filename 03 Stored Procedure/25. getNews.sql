-- ==================================================================================================
-- Procedure:   getNews
-- Purpose:     Retrieve news articles related to a specific metal
-- ==================================================================================================

DROP PROCEDURE IF EXISTS getNews;
DELIMITER $$

CREATE PROCEDURE getNews (
							IN  pReqObj JSON,
							OUT pResObj JSON
						)
BEGIN
    DECLARE v_metal_code VARCHAR(10);
    DECLARE v_news_json  JSON;

    main_block: BEGIN

        -- Extract metal_code from request
        SET v_metal_code = getJval(pReqObj, 'P_METAL_CODE');

        -- Fetch news JSON array for this metal_code
        SELECT 	news_json
        INTO 	v_news_json
        FROM 	news
        WHERE 	metal_code = v_metal_code;

        -- If no news found, return empty array
          IF v_news_json IS NULL THEN
            SET v_news_json = JSON_ARRAY();
        END IF;

        -- Build response
        SET pResObj = JSON_OBJECT(
									'status', 	'success',
									'message', 	CONCAT('News retrieved for metal ', v_metal_code),
									'news', 	v_news_json
								);

    END main_block;
END $$

DELIMITER ;

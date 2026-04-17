-- ==================================================================================================
-- Procedure:   getNews
-- Purpose:     Retrieve news articles related to a specific metal
-- ==================================================================================================

DROP PROCEDURE IF EXISTS getNews;
DELIMITER $$

CREATE PROCEDURE getNews (
							IN      pjReqObj JSON,
							INOUT   pjRespObj JSON
						)
BEGIN
    DECLARE v_asset_code        VARCHAR(50);
    DECLARE v_news_json         JSON;

    main_block: BEGIN

        -- Extract metal_code from request
        SET v_asset_code   = IFNULL(getJval(pjReqObj, 'jData.P_ASSET_CODE'), 'ALL');

        -- Fetch news JSON array for this metal_code
        IF v_asset_code = 'ALL' THEN

            SELECT JSON_ARRAYAGG(metal_news_json)
            INTO   v_news_json
            FROM metal_news;

        ELSE

            SELECT metal_news_json
            INTO v_news_json
            FROM metal_news
            WHERE asset_code = v_asset_code
            LIMIT 1;

        END IF;

        -- If no news found, return empty array
          IF v_news_json IS NULL THEN

            SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.responseCode', 1);
            SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.message', CONCAT('No news found for asset_code: ', v_asset_code));

        END IF;

        -- Build response

        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode',   0);
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',        CONCAT('News retrieved for metal ', v_asset_code));
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jData.contents',         v_news_json);

    END main_block;
END $$

DELIMITER ;


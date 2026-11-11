
DROP PROCEDURE IF EXISTS get_app_content;

DELIMITER $$

CREATE PROCEDURE get_app_content(
    IN     pjReqObj JSON,
    INOUT  pjRespObj JSON
)
BEGIN

    /* ===================== Core Variables ===================== */

    DECLARE v_this_obj       VARCHAR(32) DEFAULT 'get_app_content';
    DECLARE v_app_name       VARCHAR(100);
    DECLARE v_key            VARCHAR(100);
    DECLARE v_value          VARCHAR(100);
    DECLARE v_rec_id         INT DEFAULT NULL;

    /* ===================== Error Variables ===================== */

    DECLARE v_error_message  TEXT;

    /* ===================== Error Handler ===================== */

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET STACKED DIAGNOSTICS CONDITION 1
            v_error_message = MESSAGE_TEXT;

        SET pjRespObj = buildJSON(
            pjRespObj,
            'jHeader.responseCode',
            1
        );

        SET pjRespObj = buildJSON(
            pjRespObj,
            'jHeader.message',
            CONCAT(
                'Fetching app content failed: ',
                v_error_message
            )
        );
    END;

    /* ===================== Main ===================== */

    main_block: BEGIN

        /* ===================== Extract Parameters ===================== */

        SET v_app_name = getJval(
            pjReqObj,
            'jData.P_APP_NAME'
        );

        SET v_key = getJval(
            pjReqObj,
            'jData.P_KEY'
        );

        /* ===================== Validation ===================== */

        IF v_app_name IS NULL
           OR TRIM(v_app_name) = ''
           OR v_key IS NULL
           OR TRIM(v_key) = ''
        THEN

            SET pjRespObj = buildJSON(
                pjRespObj,
                'jHeader.responseCode',
                1
            );

            SET pjRespObj = buildJSON(
                pjRespObj,
                'jHeader.message',
                'P_APP_NAME and P_KEY are required'
            );

            LEAVE main_block;

        END IF;

        /* ===================== Fetch Content ===================== */

        SELECT
            gft_rec_id,
            object_value
        INTO
            v_rec_id,
            v_value
        FROM gft_ui_metadata
        WHERE app_name = v_app_name
          AND object_key = v_key
        ORDER BY gft_rec_id DESC
        LIMIT 1;

        /* ===================== Check Record ===================== */

        IF v_rec_id IS NULL THEN

            SET pjRespObj = buildJSON(
                pjRespObj,
                'jHeader.responseCode',
                1
            );

            SET pjRespObj = buildJSON(
                pjRespObj,
                'jHeader.message',
                'Content not found'
            );

            LEAVE main_block;

        END IF;

        /* ===================== Success Response ===================== */

        SET pjRespObj = buildJSON(
            pjRespObj,
            'jHeader.responseCode',
            0
        );

        SET pjRespObj = buildJSON(
            pjRespObj,
            'jHeader.message',
            'App content fetched successfully'
        );

        SET pjRespObj = buildJSON(
            pjRespObj,
            'jData.contents.P_KEY',
            v_key
        );

        SET pjRespObj = buildJSON(
            pjRespObj,
            'jData.contents.P_VALUE',
            v_value
        );

    END main_block;

END$$

DELIMITER ;

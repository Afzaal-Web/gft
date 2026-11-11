DROP PROCEDURE IF EXISTS upsert_Content;

DELIMITER ##

CREATE PROCEDURE `upsert_content`(
                                    IN     pjReqObj         JSON,
                                    INOUT  pjRespObj        JSON
                                    )
BEGIN

    /* ===================== Core Variables ===================== */

    DECLARE v_this_obj          VARCHAR(32)     DEFAULT 'upsert_Content';
    DECLARE v_temp              TEXT;

    /* ===================== Content Variables ===================== */

    DECLARE v_safe_json         TEXT;
    DECLARE v_view_name         VARCHAR(64);
    DECLARE v_key               VARCHAR(128);
    DECLARE v_value             TEXT;
    DECLARE v_app_name          VARCHAR(255);


    DECLARE v_existing_id    INT DEFAULT NULL;

         DECLARE v_content_json   JSON;
    DECLARE v_row_meta_data  JSON;

    /* ===================== Validation Variables ===================== */

    DECLARE v_error_message     TEXT;

    /* ===================== Error Handler ===================== */

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        GET STACKED DIAGNOSTICS CONDITION 1 v_error_message = MESSAGE_TEXT;

        SET pjRespObj = JSON_OBJECT(
                                     'status',       'error',
                                     'message',      'Upserting content failed',
                                     'system_error', v_error_message
                                    );
    END;

    /* ===================== Main ===================== */

    -- CALL debugLog(v_this_obj, '***Inside');

    main_block: BEGIN

        /* ===================== Extract and Set Parameters ===================== */

        SET v_view_name     = getJval(pjReqObj, 'jData.P_VIEW_NAME');
        SET v_key           = getJval(pjReqObj, 'jData.P_KEY');
        SET v_value         = getJval(pjReqObj, 'jData.P_VALUE');

        SET v_app_name      = getJval(pjReqObj, 'jData.P_APP_NAME');

        -- CALL debugLog(v_this_obj, 'I am here..Start');

        -- Make the value safe for JSON
        SET v_safe_json = JSON_QUOTE(v_value);
        SET v_safe_json = v_value;

        /* ===================== Validations ===================== */

        IF v_app_name IS NULL OR v_view_name IS NULL OR v_key IS NULL OR v_value IS NULL THEN

            SET pjRespObj = buildJSON(pjRespObj, 'jHeader.responseCode', 1);
            SET pjRespObj = buildJSON(pjRespObj, 'jHeader.message', 'Values can not be null.');
            LEAVE main_block;

        END IF;

        -- CALL debugLog(v_this_obj, 'I am here..END');

        -- Validate key format
        IF v_key NOT REGEXP '^[a-zA-Z0-9_-]+$' THEN
            SET pjRespObj = buildJSON(pjRespObj, 'jHeader.responseCode', 2);
            SET pjRespObj = buildJSON(pjRespObj, 'jHeader.message', 'Key name should contain only alphanumeric and a dash (hyphen)');
            LEAVE main_block;
        END IF;

        -- CALL debugLog(v_this_obj, 'All checks are okay');

        -- TODO: add routine to check aff name/rec id.

        /* ===================== Upsert Logic ===================== */

      
        SELECT gft_rec_id
        INTO v_existing_id
        FROM gft_ui_metadata
        WHERE app_name = v_app_name
          AND view_name = v_view_name
          AND object_key = v_key
        LIMIT 1
        FOR UPDATE;

        /* ===================== INSERT ===================== */

        IF v_existing_id IS NULL THEN

            SET v_row_meta_data = JSON_OBJECT(
                'created_at', DATE_FORMAT(
                    NOW(6), '%Y-%m-%d %H:%i:%s.%f'
                ),
                'created_by', 'SYSTEM',
                'updated_at', NULL,
                'updated_by', NULL
            );

            INSERT INTO gft_ui_metadata (
                app_name,
                view_name,
                object_key,
                object_value,
                row_meta_data
            )
            VALUES (
                v_app_name,
                v_view_name,
                v_key,
                v_value,
                v_row_meta_data
            );

            SET v_temp = LAST_INSERT_ID();

            SET v_content_json = JSON_OBJECT(
                'app_name', v_app_name,
                'view_name', v_view_name,
                'gft_rec_id', v_temp,
                'object_key', v_key,
                'object_value', v_value
            );

            UPDATE gft_ui_metadata
            SET gft_ui_metadata_json = v_content_json
            WHERE gft_rec_id = v_temp;

            SET pjRespObj = buildJSON(
                pjRespObj,
                'jHeader.responseCode',
                0
            );

            SET pjRespObj = buildJSON(
                pjRespObj,
                'jHeader.message',
                CONCAT(
                    'Key inserted successfully. ID: ',
                    v_temp
                )
            );

        /* ===================== UPDATE ===================== */

        ELSE

            SET v_content_json = JSON_OBJECT(
                'app_name', v_app_name,
                'view_name', v_view_name,
                'gft_rec_id', v_existing_id,
                'object_key', v_key,
                'object_value', v_value
            );

            UPDATE gft_ui_metadata
            SET
                object_value = v_value,

                gft_ui_metadata_json = v_content_json,

                row_meta_data = JSON_SET(
                    COALESCE(
                        row_meta_data,
                        JSON_OBJECT()
                    ),
                    '$.updated_at',
                    DATE_FORMAT(
                        NOW(6), '%Y-%m-%d %H:%i:%s.%f'
                    ),
                    '$.updated_by',
                    'SYSTEM'
                )

            WHERE gft_rec_id = v_existing_id;

            SET pjRespObj = buildJSON(
                pjRespObj,
                'jHeader.responseCode',
                0
            );

            SET pjRespObj = buildJSON(
                pjRespObj,
                'jHeader.message',
                'Existing key updated successfully'
            );

        END IF;

    END main_block;

    -- CALL debugLog(v_this_obj, '***Exiting');

    -- insert general code here like LOG
    -- call log proc

END ##

DELIMITER ;
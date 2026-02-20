DROP PROCEDURE IF EXISTS savePreferences;

DELIMITER $$

CREATE PROCEDURE savePreferences(
									IN  pReqObj JSON,
									OUT pResObj JSON
								)
BEGIN

    DECLARE v_login_id              VARCHAR(255);
    DECLARE v_preference_key        VARCHAR(255);
    DECLARE v_preference_value      VARCHAR(255);

    DECLARE v_customer_rec_id       INT;
    DECLARE v_existing_pref_id      INT;
    DECLARE v_old_value             VARCHAR(255);

    DECLARE v_app_preferences_json  JSON;
    DECLARE v_existing_json         JSON;
    DECLARE v_row_metadata          JSON;

    DECLARE v_effective_from        DATETIME;
    DECLARE v_effective_until       DATETIME;

    main_block: BEGIN

        -- =========================
        -- Extract values
        -- =========================
        SET v_login_id         = getJval(pReqObj, 'P_LOGIN_ID');
        SET v_preference_key   = getJval(pReqObj, 'P_PREFERENCE_KEY');
        SET v_preference_value = getJval(pReqObj, 'P_PREFERENCE_VALUE');

        -- =========================
        -- Validation
        -- =========================
        IF isFalsy(v_login_id) OR isFalsy(v_preference_key) THEN
            SET pResObj = JSON_OBJECT(
										'status', 'error',
										'message', 'Login ID, Preference Key are required.'
									);
            LEAVE main_block;
        END IF;

        -- =========================
        -- Get Customer
        -- =========================
        SELECT  customer_rec_id
        INTO    v_customer_rec_id
        FROM 	customer
        WHERE 	user_name = v_login_id
        OR 	  	email     = v_login_id
        OR 	  	phone     = v_login_id
        LIMIT 1;

        IF v_customer_rec_id IS NULL THEN
            SET pResObj = JSON_OBJECT(
										'status', 'error',
										'message', 'Customer not found'
									);
            LEAVE main_block;
        END IF;

        -- =========================
        -- Check if preference exists
        -- =========================
        SELECT  preference_rec_id, 	 preference_value, 	app_preferences_json
        INTO    v_existing_pref_id,  v_old_value, 		v_existing_json
        FROM    app_preferences
        WHERE   customer_rec_id  = v_customer_rec_id
        AND     preference_key   = v_preference_key
        LIMIT 1;

        -- =========================
        -- Determine Effective Dates
        -- =========================
        SET v_effective_from  = NULL;
        SET v_effective_until = NULL;

        -- FIRST TIME
        IF v_existing_pref_id IS NULL THEN

            SET v_effective_from  = NOW();
            SET v_effective_until = DATE_ADD(NOW(), INTERVAL 365 DAY);

        ELSE

            -- If value cleared → expire immediately
            IF isFalsy(v_preference_value) THEN

                SET v_effective_from  = NULL;
                SET v_effective_until = NOW();

            -- If value changed → reset validity
            ELSEIF v_old_value <> v_preference_value THEN

                SET v_effective_from  = NOW();
                SET v_effective_until = DATE_ADD(NOW(), INTERVAL 365 DAY);

            -- If same value → keep old dates
            ELSE

                SET v_effective_from  = getJval(v_existing_json,  '$.preference_behavior.effective_from');
                SET v_effective_until = getJval(v_existing_json, '$.preference_behavior.effective_until');

            END IF;

        END IF;

        -- =========================
        -- Prepare JSON
        -- =========================
        SET v_app_preferences_json = getTemplate('app_preferences');

        SET v_app_preferences_json = JSON_SET(
												v_app_preferences_json,
												'$.preference_behavior.is_user_editable', TRUE,
												'$.preference_behavior.is_system_defined', TRUE,
												'$.preference_behavior.effective_from', v_effective_from,
												'$.preference_behavior.effective_until', v_effective_until
											);

        -- =========================
        -- Row metadata
        -- =========================
        SET v_row_metadata = getTemplate('row_metadata');

        SET v_row_metadata = JSON_SET(
										v_row_metadata,
										'$.status', 'Active',
										'$.updated_at', NOW(),
										'$.updated_by', 'SYSTEM'
									);

        -- =========================
        -- INSERT or UPDATE
        -- =========================
        IF v_existing_pref_id IS NULL THEN

            INSERT INTO app_preferences
            SET customer_rec_id      = v_customer_rec_id,
                preference_key       = v_preference_key,
                preference_value     = v_preference_value,
                app_preferences_json = v_app_preferences_json,
                row_metadata         = v_row_metadata;

        ELSE

            UPDATE app_preferences
            SET preference_value      = v_preference_value,
                app_preferences_json  = v_app_preferences_json,
                row_metadata          = v_row_metadata
            WHERE preference_rec_id = v_existing_pref_id;

        END IF;

        -- =========================
        -- Success Response
        -- =========================
        SET pResObj = JSON_OBJECT(
            'status', 'success',
            'message', 'Preference saved successfully'
        );

    END main_block;

END $$

DELIMITER ;

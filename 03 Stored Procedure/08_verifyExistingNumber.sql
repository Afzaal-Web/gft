-- ==================================================================================================
-- Procedure: 	verifiyExistingNumber
-- Purpose:   	Check DB for existing users info. If existing user then error message. 
-- 				If found elsewhere, return person info. If not found then return blank. 
-- Functions and Procs used in this Pro:
				-- isFalsy(): SF				validate the values come from reqObj
				-- genOtp(): SP					SP to generate OTP
-- ==================================================================================================

DROP PROCEDURE IF EXISTS verifiyExistingNumber;
DELIMITER $$

CREATE PROCEDURE verifiyExistingNumber(
										IN     pjReqObj   JSON,
										INOUT  pjRespObj  JSON
									  )
BEGIN
    DECLARE v_phone          			VARCHAR(20);
    DECLARE v_err_msg        			TEXT;
    DECLARE v_reverser_lookup_json   	JSON;

    /* ===================== Error Handler ===================== */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET STACKED DIAGNOSTICS CONDITION 1 v_err_msg = MESSAGE_TEXT;

		SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', CONCAT('Unexpected Error - Verification failed ', v_err_msg));

    END;

    /* ===================== Main ===================== */
    main_block: BEGIN

        /* ===================== Extract Phone ===================== */
        SET v_phone = getJval(pjReqObj, 'jData.P_PHONE_NUM');

        IF isFalsy(v_phone) THEN
			SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
			SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',      'Phone number is required'); 
            LEAVE main_block;
        END IF;

        /* ===================== 1. CUSTOMER CHECK ===================== */
        IF EXISTS (
					SELECT 1
					FROM   customer
					WHERE  phone = v_phone
		) THEN
			SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
			SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',      'User already exists with this phone number'); 									
		    LEAVE main_block;
        END IF;

        /* ===================== 2. Reverse Lookup ===================== */
        IF EXISTS (
					SELECT 1
					FROM   reverse_lookup
					WHERE  phone = v_phone
		) THEN

            -- Fetch reverse lookup data
            SELECT JSON_OBJECT(
								'first_name', 	first_name,
								'last_name',  	last_name,
								'email',      	email,
								'address',    	address,
								'city',       	city,
								'state',      	state,
								'zip_code',   	zip_code
							)
            INTO  v_reverser_lookup_json
            FROM  reverse_lookup
            WHERE phone = v_phone
            LIMIT 1;

            -- Generate OTP
            CALL genOtp(
                    JSON_OBJECT(
                        'jData', JSON_OBJECT(
												'P_CONTACT_TYPE', 'phone',
												'P_DESTINATION',  v_phone,
												'P_PURPOSE',      'For phone number verification at the time of signup'
											)
                    			),
                    				pjRespObj
                			);

            -- If genOtp failed (e.g. cooldown), leave immediately with genOtp's error message intact
            IF getJval(pjRespObj, 'jHeader.responseCode') != 0 THEN
                LEAVE main_block;
            END IF;

            -- genOtp succeeded, now write our own success response
			SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', '0');
			SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',      'Success - Phone exists in reverse lookup. Get the user info from jData.contents and proceed with registration.');
			SET pjRespObj = buildJSONSmart(pjRespObj, 'jData.contents',       v_reverser_lookup_json);

            LEAVE main_block;
        END IF;

        /* ===================== 3. NEW USER ===================== */

        -- Generate OTP
        CALL genOtp(
                JSON_OBJECT(
                    'jData', JSON_OBJECT(
                        'P_CONTACT_TYPE', 'phone',
                        'P_DESTINATION',  v_phone,
                        'P_PURPOSE',      'For phone number verification at the time of signup'
                    )
                ),
                pjRespObj
            );

        -- If genOtp failed (e.g. cooldown), leave immediately with genOtp's error message intact
        IF getJval(pjRespObj, 'jHeader.responseCode') != 0 THEN
            LEAVE main_block;
        END IF;

        -- genOtp succeeded, now write our own success response
		SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 0);
		SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',      'New user - Phone number is not found, proceed with registration.');

    END main_block;
END $$

DELIMITER ;
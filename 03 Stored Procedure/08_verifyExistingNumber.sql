-- ==================================================================================================
-- Procedure: 					verifiyExistingNumber
-- Purpose:   					Check DB for existing users info. If existing user then error message. 
-- 								If found elsewhere, return person info. If not found then return blank. 
-- Functions and Procs used in this Pro:
								-- isFalsy(): SF					validate the values come from reqObj
								-- generateOtp(): SP				SP to generate OTP
-- ===================================================================================================

DROP PROCEDURE IF EXISTS verifiyExistingNumber;
DELIMITER $$

CREATE PROCEDURE verifiyExistingNumber(
										IN  pjReqObj JSON,
										OUT psResObj JSON
									  )
BEGIN
    DECLARE v_phone          			VARCHAR(20);
    DECLARE v_err_msg        			TEXT;
    DECLARE v_reverser_lookup_json   	JSON;

    /* ===================== Error Handler ===================== */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET STACKED DIAGNOSTICS CONDITION 1 v_err_msg = MESSAGE_TEXT;
        SET psResObj = JSON_OBJECT(
									'status',        	'error',
									'status_code',   	'1',
									'message',       	'Verification failed',
									'system_error',  	v_err_msg
								);
    END;

    /* ===================== Main ===================== */
    main_block: BEGIN

        /* ===================== Extract Phone ===================== */
        SET v_phone 	= getJval(pjReqObj, 'P_PHONE_NUM');

        IF isFalsy(v_phone) THEN
            SET psResObj = JSON_OBJECT(
										'status',      	'error',
										'status_code', 	'1',
										'message',     	'Phone number is required'
									);
            LEAVE main_block;
        END IF;

        /* ===================== 1. CUSTOMER CHECK ===================== */
        IF EXISTS (
					SELECT 1
					FROM customer
					WHERE phone = v_phone
		) THEN
		  SET psResObj = JSON_OBJECT(
										'status',      	'error',
										'status_code', 	'1',
										'message',     	'User already exists with this phone number'
									);
		  LEAVE main_block;
        END IF;

        /* ===================== 2. Reverse Lookup in Marketing Table ===================== */
        IF EXISTS (
					SELECT 1
					FROM reverse_lookup
					WHERE phone = v_phone
		  ) THEN

            -- Fetch marketing data
            SELECT JSON_OBJECT(
								'first_name', 	first_name,
								'last_name',  	last_name,
								'email',      	email,
								'address',    	address,
								'city',       	city,
								'state',      	state,
								'zip_code',   	zip_code
							)
            INTO	v_reverser_lookup_json
            FROM 	reverse_lookup
            WHERE 	phone = v_phone
            LIMIT 	1;

            -- Generate OTP 
            CALL genOtp('loginid', v_phone, 'For phone number verification at the time of signup');

            SET psResObj = JSON_OBJECT(
										'status',      		'success',
										'status_code', 		'0',
										'data',        		v_reverser_lookup_json
            );

            LEAVE main_block;
        END IF;

        /* ===================== 3. NEW USER ===================== */

        -- Generate OTP 
        CALL genOtp( 'loginid', v_phone, 'PHONE REGISTRATION');

        SET psResObj = JSON_OBJECT(
									'status',      'success',
									'status_code', '0',
									'source',      'new_user'
								);

    END main_block;
END $$

DELIMITER ;

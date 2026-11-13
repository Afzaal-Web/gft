-- ==================================================================================================
-- Procedure:   verifyOtp
-- Purpose:     Verify user OTP based on contact type and return JSON result
-- ==================================================================================================

DROP PROCEDURE IF EXISTS verifyOtp;

DELIMITER $$

CREATE PROCEDURE verifyOtp(
                            IN    pjReqObj 	JSON,
							INOUT pjRespObj   JSON
						 )
BEGIN
    DECLARE v_otp_rec_id    INT;
    DECLARE v_actual_otp    CHAR(6);
    DECLARE v_expiry        DATETIME;
    DECLARE v_retries       INT;
    DECLARE v_status        VARCHAR(20);
    DECLARE v_otp_token		JSON;
    
	DECLARE vContactType    ENUM('email','phone','loginid');
    DECLARE vDestination    VARCHAR(255);
    DECLARE vPurpose        VARCHAR(100);
    DECLARE vOtpCode        CHAR(6);
	DECLARE vForgot VARCHAR(30) DEFAULT NULL;
    
    DECLARE v_login_id      VARCHAR(100);

	DECLARE v_err_msg 		TEXT;
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN

			GET STACKED DIAGNOSTICS CONDITION 1 v_err_msg = MESSAGE_TEXT;
			SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
			SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', CONCAT('Unexpected Error - ', v_err_msg));

	END;
    
	main_block: BEGIN
    
		-- =========================
			-- Extract values from JSON
		-- =========================
		SET vContactType 		= getJval(pjReqObj, 'jData.P_CONTACT_TYPE');
		SET vDestination 		= getJval(pjReqObj, 'jData.P_DESTINATION');
		SET vOtpCode     		= getJval(pjReqObj, 'jData.P_OTP_CODE');
		SET vPurpose    		= getJval(pjReqObj, 'jData.P_PURPOSE');

		IF isFalsy(vContactType) OR isFalsy(vDestination) OR isFalsy(vOtpCode) OR isFalsy(vPurpose) THEN
    		
			SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
    		SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'Missing required parameters');

    		LEAVE main_block;
		END IF;

		-- =========================
		-- Get latest OTP
		-- =========================
		SELECT  otp_rec_id,      otp_code,       expires_at,     otp_retries,    forgot_type
		INTO    v_otp_rec_id,    v_actual_otp,   v_expiry,       v_retries,      vForgot
		FROM    otp
		WHERE   contact_type = vContactType
		AND     destination  = vDestination
		AND     purpose      = vPurpose
		ORDER BY otp_rec_id DESC
		LIMIT   1;


		-- =========================
		-- No OTP found
		-- =========================
		IF v_otp_rec_id IS NULL THEN

			SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.responseCode', 1);

	    	SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.message', 'OTP not found' );  
			
			LEAVE main_block;
		END IF;

		-- =========================
		-- Validate Forgot Type
		-- =========================
		IF vPurpose = 'FORGOT LOGIN ID' THEN

			IF vForgot IS NULL OR vForgot NOT IN ('username', 'email', 'phone') THEN

				SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
				SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'Invalid or missing forgot_type in OTP record.');

				LEAVE main_block;
			END IF;

		END IF;

		-- =========================
		-- OTP expired
		-- =========================
		IF v_expiry IS NULL OR NOW() >= v_expiry THEN

			SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.responseCode', 1);

	    	SET pjRespObj = buildJSONSmart( pjRespObj,
								   			'jHeader.message', 'OTP EXPIRED'
							               );  
			
			LEAVE main_block;
		END IF;

		-- =========================
		-- Validate OTP Retries
		-- =========================
		IF v_retries IS NULL OR v_retries <= 0 THEN

			SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
			SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'OTP has no attempts remaining.');

			LEAVE main_block;
		END IF;

		-- =========================
		-- OTP mismatch (000000 allowed for development only)
		-- =========================
		IF v_actual_otp <> vOtpCode THEN
			IF v_retries > 1 THEN
				UPDATE  otp
				SET 	otp_retries = otp_retries - 1
				WHERE 	otp_rec_id 	= v_otp_rec_id;
				
				SET 	v_status 	= 'INVALID';
				SET 	v_retries 	= v_retries - 1;
			ELSE
				-- No retries left
				UPDATE otp
				SET    otp_retries 	= 0,
					   expires_at 	= NOW()
				WHERE  otp_rec_id	= v_otp_rec_id;
				
				SET v_status 		= 'FAILED';
				SET v_retries 		= 0;
			END IF;

			SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.responseCode', 1);

	    	SET pjRespObj = buildJSONSmart( pjRespObj,
								   			'jHeader.message', CONCAT('OTP IS ',v_status, ', ', v_retries, ' retries left.')
							               );  
			LEAVE main_block;
		END IF;

		-- =========================
		-- OTP SUCCESS
		-- =========================
		UPDATE 	otp
		SET 	expires_at 		= NOW(),
				otp_retries 	= 0
		WHERE otp_rec_id = v_otp_rec_id;
		
		-- =========================
		-- Call Handle Otp Success SP
		-- =========================
		
		CALL handleOtpSuccess(vContactType, vDestination, vPurpose, vForgot, v_otp_token);
		
		
			-- =========================
			-- Final Success Response
			-- =========================

		-- If handleOtpSuccess failed, leave with its error message intact
		-- =========================
		-- Validate Handle OTP Response
		-- =========================
		IF COALESCE(
			CAST(getJval(v_otp_token, 'jHeader.responseCode') AS SIGNED),
			1
		) <> 0 THEN

			SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
			SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',
								COALESCE(getJval(v_otp_token, 'jHeader.message'),
										'OTP verification processing failed.'));

			LEAVE main_block;
		END IF;

		-- handleOtpSuccess succeeded, copy its full response into pjRespObj
		SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 0);
		SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', getJval(v_otp_token, 'jHeader.message'));  


		IF getJval(v_otp_token, 'jData.contents.reset_token') IS NOT NULL THEN
		
			SET pjRespObj = buildJSONSmart(pjRespObj, 'jData.contents.reset_token', getJval(v_otp_token, 'jData.contents.reset_token'));
			SET pjRespObj = buildJSONSmart(pjRespObj, 'jData.contents.reset_token_expires_in_minutes', getJval(v_otp_token, 'jData.contents.reset_token_expires_in_minutes'));

		END IF;


	
		-- =========================
		-- Return Customer JSON and Auth Token for LOGIN
		-- =========================

		IF vPurpose = 'LOGIN' THEN

			SET pjRespObj = buildJSONSmart(pjRespObj, 'jData.contents',           JSON_EXTRACT(v_otp_token, '$.jData.contents'));
			SET pjRespObj = buildJSONSmart(pjRespObj, 'jData.user_auth_token',    getJval(v_otp_token, 'jData.user_auth_token'));
			SET pjRespObj = buildJSONSmart(pjRespObj, 'jData.user_session_id',    getJval(v_otp_token, 'jData.user_session_id'));
			SET pjRespObj = buildJSONSmart(pjRespObj, 'jData.session_expires_at', getJval(v_otp_token, 'jData.session_expires_at'));

		END IF;


			
    END main_block;
    -- logging
END $$

DELIMITER ;

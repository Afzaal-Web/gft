-- ==================================================================================================
-- Procedure:   verifyOtp
-- Purpose:     Verify user OTP based on contact type and return JSON result
-- ==================================================================================================

DROP PROCEDURE IF EXISTS verifyOtp;

DELIMITER $$

CREATE PROCEDURE verifyOtp(
                            IN pReqObj 		JSON,
							OUT psResObj     	JSON
						 )
BEGIN
    DECLARE v_otp_rec_id    INT;
    DECLARE v_actual_otp    CHAR(6);
    DECLARE v_expiry        DATETIME;
    DECLARE v_retries       INT;
    DECLARE v_status        VARCHAR(20);
    DECLARE v_otp_token		VARCHAR(100);
    
	DECLARE vContactType    ENUM('email','phone','loginid');
    DECLARE vDestination    VARCHAR(255);
    DECLARE vPurpose        VARCHAR(100);
    DECLARE vOtpCode        CHAR(6);
    
    DECLARE v_login_id      VARCHAR(100);
    
	main_block: BEGIN
    
		-- =========================
			-- Extract values from JSON
		-- =========================
		SET vContactType 		= getJval(pjReqObj, 'P_CONTACT_TYPE');
		SET vDestination 		= getJval(pjReqObj, 'P_DESTINATION');
		SET vOtpCode     		= getJval(pjReqObj, 'P_OTP_CODE');
		SET vPurpose    		= getJval(pReqJson, 'P_PURPOSE');

		-- =========================
		-- Get latest OTP
		-- =========================
		SELECT otp_rec_id, 		otp_code, 		expires_at, 	otp_retries
		INTO   v_otp_rec_id, 	v_actual_otp, 	v_expiry, 		v_retries
		FROM   otp
		WHERE  contact_type = pContactType
		AND    destination  = vDestination
		AND    purpose      = vPurpose
		ORDER BY otp_rec_id DESC
		LIMIT 1
		FOR UPDATE;

		-- =========================
		-- No OTP found
		-- =========================
		IF v_otp_rec_id IS NULL THEN
			SET psResObj = JSON_OBJECT('status','NOT_FOUND');
			
			LEAVE main_block;
		END IF;

		-- =========================
		-- OTP expired
		-- =========================
		IF NOW() > v_expiry THEN
			SET psResObj = JSON_OBJECT('status','EXPIRED');
			
			LEAVE main_block;
		END IF;

		-- =========================
		-- OTP mismatch
		-- =========================
		IF v_actual_otp <> pOtpCode THEN
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

			SET psResObj = JSON_OBJECT(
										'status',			 v_status,
										'remaining_retries', v_retries
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
		-- Call Success Otp SP
		-- =========================
		
		CALL handleOtpSuccess(vContactType, vDestination, vPurpose, v_otp_token);
		
		
			-- =========================
			-- Final Success Response
			-- =========================
			SET psResObj = JSON_OBJECT(
				'status', 'SUCCESS',
				'token', v_otp_token
			);
			
    END main_block;
    -- logging
END $$

DELIMITER ;

-- ==================================================================================================
-- Procedure:   forgotLoginID
-- Purpose:     Handle "Forgot Login ID" flow securely
-- ==================================================================================================

DROP PROCEDURE IF EXISTS forgotLoginID;

DELIMITER $$

CREATE PROCEDURE forgotLoginID(
								IN      pjReqObj   JSON,      
								INOUT   pjRespObj   JSON       
							)
BEGIN
    DECLARE v_forgot           VARCHAR(30);
    DECLARE v_email         	VARCHAR(255);
    DECLARE v_phone         	VARCHAR(20);
    DECLARE v_cnic		      	VARCHAR(50);
    DECLARE v_shared_otp        VARCHAR(6);
    
    DECLARE v_login_id			VARCHAR(100);
    DECLARE v_contact_type     VARCHAR(20);
    DECLARE v_destination      VARCHAR(255);

    DECLARE v_err_msg 		    TEXT;
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
			GET STACKED DIAGNOSTICS CONDITION 1 v_err_msg = MESSAGE_TEXT;

			SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
			SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', CONCAT('Unexpected Error - ', v_err_msg));

	END;
    
	main_block: BEGIN

    -- Extract info from input JSON
    SET v_email    	     = getJval(pjReqObj, 'jData.P_EMAIL');
    SET v_phone    	     = getJval(pjReqObj, 'jData.P_PHONE');
    SET v_cnic 		     = getJval(pjReqObj, 'jData.P_CNIC');
    SET v_shared_otp    = getJval(pjReqObj, 'jData.P_PRESET_OTP');
     SET v_forgot       = LOWER(TRIM(getJval(pjReqObj, 'jData.P_FORGOT')));

    -- =========================
    -- Validate Forgot Type
    -- =========================
    IF v_forgot IS NULL OR v_forgot NOT IN ('username', 'email', 'phone') THEN

        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'P_FORGOT must be username, email or phone.');

        LEAVE main_block;
    END IF;

    -- =========================
    -- Validate Recovery Contact
    -- =========================
    IF (v_forgot = 'email' AND v_phone IS NULL)
        OR (v_forgot = 'phone' AND v_email IS NULL)
        OR (v_forgot = 'username' AND v_email IS NULL AND v_phone IS NULL) THEN

        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'A valid recovery contact is required.');

        LEAVE main_block;
    END IF;
    -- ============== Find user account =============
    SELECT user_name
    INTO   v_login_id
    FROM   customer
     WHERE   (v_cnic IS NULL OR national_id = v_cnic)
        AND     (
                    (v_forgot = 'email' AND phone = v_phone)
                    OR
                    (v_forgot = 'phone' AND email = v_email)
                    OR
                    (v_forgot = 'username' AND (
                        (v_email IS NOT NULL AND email = v_email)
                        OR
                        (v_phone IS NOT NULL AND phone = v_phone)
                    ))
                )
        LIMIT   1;

     -- =========================
        -- Validate Customer
    -- =========================
        IF v_login_id IS NULL THEN

            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'Customer not found with provided details.');

            LEAVE main_block;
        END IF;


        -- =========================
        -- Set OTP Destination
        -- =========================
        IF v_forgot = 'email' OR (v_forgot = 'username' AND v_email IS NULL) THEN

            SET v_contact_type = 'phone';
            SET v_destination  = v_phone;

        ELSE

            SET v_contact_type = 'email';
            SET v_destination  = v_email;

        END IF;

        -- =========================
        -- Generate OTP
        -- =========================
        CALL genOtp(
                    JSON_OBJECT(
                        'jData', JSON_OBJECT(
                            'P_CONTACT_TYPE',    v_contact_type,
                            'P_DESTINATION',     v_destination,
                            'P_PURPOSE',         'FORGOT LOGIN ID',
                            'P_FORGOT',          v_forgot,
                            'P_PRESET_OTP',      v_shared_otp
                        )
                    ),
                    pjRespObj
                   );


    END main_block;
    
END $$

DELIMITER ;

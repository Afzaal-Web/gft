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
    DECLARE v_email         	VARCHAR(255);
    DECLARE v_phone         	VARCHAR(20);
    DECLARE v_cnic		      	VARCHAR(50);
    
    DECLARE v_login_id			VARCHAR(100);

    DECLARE v_err_msg 		    TEXT;
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
			GET STACKED DIAGNOSTICS CONDITION 1 v_err_msg = MESSAGE_TEXT;

			SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
			SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', CONCAT('Unexpected Error - ', v_err_msg));

	END;
    
	main_block: BEGIN

    -- Extract info from input JSON
    SET v_email    	= getJval(pjReqObj, 'jData.P_EMAIL');
    SET v_phone    	= getJval(pjReqObj, 'jData.P_PHONE');
    SET v_cnic 		= getJval(pjReqObj, 'jData.P_CNIC');

    -- ============== Find user account =============
    SELECT user_name
    INTO   v_login_id
    FROM   customer
    WHERE (
			(email = v_email AND v_email IS NOT NULL)  OR  (phone = v_phone AND v_phone IS NOT NULL)
		  )
		  AND national_id = v_cnic
    LIMIT 1;

    IF v_login_id IS NULL THEN
        -- No user found
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
    	SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'customer not found');

        LEAVE main_block;
    END IF;

    -- ============ Generate OTP to verified contact ============

    CALL genOtp(
                JSON_OBJECT(
                    'jData', JSON_OBJECT(
                        'P_CONTACT_TYPE', CASE WHEN v_email IS NOT NULL THEN 'email' ELSE 'phone' END,
                        'P_DESTINATION',  COALESCE(v_email, v_phone),
                        'P_PURPOSE',      'FORGOT LOGIN ID'
                    )
                ),
                pjRespObj
            );

    END main_block;
    
END $$

DELIMITER ;

-- ==================================================================================================
-- Procedure:   forgotLoginID
-- Purpose:     Handle "Forgot Login ID" flow securely
-- ==================================================================================================

DROP PROCEDURE IF EXISTS forgotLoginID;

DELIMITER $$

CREATE PROCEDURE forgotLoginID(
								IN  pjReqObj   JSON,      
								OUT pjResObj   JSON       
							)
BEGIN
    DECLARE v_email         	VARCHAR(255);
    DECLARE v_phone         	VARCHAR(20);
    DECLARE v_cnic		      	VARCHAR(50);
    
    DECLARE v_login_id			VARCHAR(100);
    
	main_block: BEGIN

    -- Extract info from input JSON
    SET v_email    	= getJval(pjReqObj, 'P_EMAIL');
    SET v_phone    	= getJval(pjReqObj, 'P_PHONE');
    SET v_cnic 		= getJval(pjReqObj, 'P_CNIC');

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
        SET pjResObj = JSON_OBJECT(
									'status', 		'USER_NOT_FOUND',
									'message', 		'Invalid provided information.'
								);
        LEAVE main_block;
    END IF;

    -- ============ Generate OTP to verified contact ============
     CALL genOtp(
				CASE WHEN v_email IS NOT NULL THEN 'email' ELSE 'phone' END,
				COALESCE(v_email, v_phone),
                'FORGOT LOGIN ID'
    );
	

    -- ============= Prepare response ============
    SET pjResObj = JSON_OBJECT(
								'status', 			'OTP_SENT',
								'message', 			'OTP has been sent to your verified contact. Use it to retrieve your login ID.'
							);
    END main_block;
    
END $$

DELIMITER ;

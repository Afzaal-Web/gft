-- ==================================================================================================
-- Procedure:   handleOtpSuccess
-- Purpose:     Execute business logic after successful OTP verification
-- ==================================================================================================

DROP PROCEDURE IF EXISTS handleOtpSuccess;

DELIMITER $$

CREATE PROCEDURE handleOtpSuccess(
									IN pContactType    ENUM('email','phone','loginid'),
									IN pDestination    VARCHAR(255),
                                    IN pPurpose        VARCHAR(100),
                                    OUT pResObj			JSON
								)
BEGIN

	DECLARE v_customer_rec_id  	INT;
    DECLARE v_login_id        	VARCHAR(100);
	DECLARE v_email         	VARCHAR(255);
    DECLARE v_phone         	VARCHAR(20);
    DECLARE v_reset_token    	VARCHAR(100);

    main_block: BEGIN
    
    -- Get customer first
        SELECT 	 customer_rec_id, 		user_name, 	 email,   phone
        INTO  	 v_customer_rec_id, 	v_login_id,  v_email, v_phone
        FROM   	 customer
        WHERE   (email = pDestination OR phone = pDestination)
        LIMIT 1;
        
         -- If customer not found
        IF v_customer_rec_id IS NULL THEN
            SET pResObj = JSON_OBJECT(
										'status','FAILED',
										'message','Customer not found'
									);
            LEAVE main_block;
        END IF;
        CASE pPurpose

            -- =====================================================
            -- FORGOT LOGIN ID
            -- =====================================================
            WHEN 'FORGOT LOGIN ID' THEN

                  IF pContactType = 'loginid' THEN
                    -- Send to both email & phone if exist
                    IF v_email IS NOT NULL THEN
                        INSERT INTO outbound_msgs(channel, recipient, message_body, created_at)
                        VALUES('email', v_email, CONCAT('Your Login ID is: ', v_login_id), NOW());
                    END IF;
                    IF v_phone IS NOT NULL THEN
                        INSERT INTO outbound_msgs(channel, recipient, message_body, created_at)
                        VALUES('phone', v_phone, CONCAT('Your Login ID is: ', v_login_id), NOW());
                    END IF;
                    
                    ELSE
                    INSERT INTO outbound_msgs(channel, recipient, message_body, created_at)
                    VALUES(pContactType, pDestination, CONCAT('Your Login ID is: ', v_login_id), NOW());
                END IF;
                    
					SET pResObj = JSON_OBJECT(
												'status','SUCCESS',
												'message','Login ID sent successfully'
											);	

            

            -- =====================================================
            -- RESET PASSWORD
            -- =====================================================
            WHEN 'RESET PASSWORD' THEN
            
             SET v_reset_token = UUID();
             
			UPDATE customer 
			SET customer_json = JSON_SET(customer_json,
										'$.otp_reset_token', 		v_reset_token,
										 '$.reset_token_expiry', 	NOW() + INTERVAL 10 MINUTE
										)
			WHERE customer_rec_id = v_customer_id;
						
			SET pResObj = JSON_OBJECT(
										'status',				'SUCCESS',
										'reset_token', 			v_reset_token,
										'expires_in_minutes', 	10
									);


            -- =====================================================
            -- REGISTER (placeholder)
            -- =====================================================
            WHEN 'REGISTER' THEN
            
			-- some code
            SET pResObj = JSON_OBJECT(
                    'status','SUCCESS',
                    'message','OTP verified for registration'
                );
                BEGIN END;

            -- =====================================================
            -- DEFAULT (do nothing)
            -- =====================================================
            ELSE
            
             SET pResObj = JSON_OBJECT(
                    'status','FAILED',
                    'message','Invalid purpose'
                );
                BEGIN END;

        END CASE;

    END main_block;

END $$

DELIMITER ;

-- ==================================================================================================
-- Procedure:   handleOtpSuccess
-- Purpose:     Execute business logic after successful OTP verification
-- ==================================================================================================

DROP PROCEDURE IF EXISTS handleOtpSuccess;

DELIMITER $$

CREATE PROCEDURE handleOtpSuccess(
									IN    pContactType    ENUM('email','phone','loginid'),
									IN    pDestination    VARCHAR(255),
                                    IN    pPurpose        VARCHAR(100),
                                    IN    pForgot         VARCHAR(30),
                                    OUT   pjRespObj		  JSON
								)
BEGIN

	DECLARE v_customer_rec_id   	INT;
    DECLARE v_customer_json         JSON;
    DECLARE v_login_id        	    VARCHAR(100);
	DECLARE v_email         	    VARCHAR(255);
    DECLARE v_phone         	    VARCHAR(20);
    DECLARE v_reset_token    	    VARCHAR(100);
    DECLARE v_message_guid          VARCHAR(100);
    DECLARE v_outbound_msgs_rec_id  INT;

    DECLARE v_token_req_obj         JSON;
    DECLARE v_token_resp_obj        JSON;
    DECLARE v_user_auth_token       VARCHAR(64);
    DECLARE v_user_session_id       VARCHAR(36);
    DECLARE v_token_expires_at      VARCHAR(30);

    DECLARE v_forgot_value       VARCHAR(255);
    DECLARE v_message_subject    VARCHAR(255);
    DECLARE v_message_body       TEXT;

    DECLARE v_outbound_msgs_json   	JSON;
    DECLARE v_row_metadata         	JSON;

    DECLARE v_err_msg               TEXT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN

        GET STACKED DIAGNOSTICS CONDITION 1 v_err_msg = MESSAGE_TEXT;
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
        SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', CONCAT('Unexpected Error - ', v_err_msg));

    END;

    SET pjRespObj       = getTemplate('reqResp');

    main_block: BEGIN
    
    IF pPurpose <> 'REGISTER' THEN
    -- Get customer first
        SELECT 	 customer_rec_id, 		user_name, 	 email,   phone
        INTO  	 v_customer_rec_id, 	v_login_id,  v_email, v_phone
        FROM   	 customer
        WHERE   (email = pDestination OR phone = pDestination)
        LIMIT 1;
        
         -- If customer not found
        IF isFalsy(v_customer_rec_id) THEN

            SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.responseCode', 1);
	    	SET pjRespObj = buildJSONSmart( pjRespObj,'jHeader.message', 'Customer not found');

            LEAVE main_block;
        END IF;

    END IF;

        SET v_outbound_msgs_json = getTemplate('outbound_msgs');

        SET v_outbound_msgs_json = JSON_SET(v_outbound_msgs_json,
                                            '$.parent_message_table_name',              'customer',
                                            '$.parent_message_table_rec_id',            v_customer_rec_id,
                                            '$.business_context.module_name',           'AUTH',
                                            '$.business_context.message_type',          'TRANSACTIONAL',
                                            '$.business_context.login_id',              v_login_id,
                                            '$.delivery_config.channel_number',         1,
                                            '$.delivery_config.priority_level',         1,
                                            '$.delivery_config.is_need_tracking',       TRUE,
                                            '$.sender_info.from_name',                  'GFT',
                                            '$.sender_info.from_address',               'no-reply@gft.com',
                                            '$.scheduling.scheduled_at',                NOW(),
                                            '$.scheduling.retry_interval',              60,
                                            '$.lifecycle_status.current_status',        'PENDING',
                                            '$.lifecycle_status.delivery_status',       'NOT_SENT',
                                            '$.lifecycle_status.send_attempts',         0,
                                            '$.lifecycle_status.number_of_retries',     3
                                        );

        -- =========================
		-- Row Metadata
		-- =========================
		SET v_row_metadata = getTemplate('row_metadata');

		SET v_row_metadata = JSON_SET(v_row_metadata,
									 '$.created_at', NOW(),
									 '$.created_by', 'SYSTEM'
									);

        CASE pPurpose
           

        -- =====================================================
        -- FORGOT LOGIN ID
        -- =====================================================
        WHEN 'FORGOT LOGIN ID' THEN

            -- =========================
            -- Validate Forgot Type
            -- =========================
            IF pForgot IS NULL OR pForgot NOT IN ('username', 'email', 'phone') THEN

                SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
                SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'Invalid forgot type.');

                LEAVE main_block;
            END IF;

            -- =========================
            -- Set Recovery Information
            -- =========================
            CASE pForgot

                WHEN 'username' THEN

                    SET v_forgot_value       = v_login_id;
                    SET v_message_subject    = 'Your Username';
                    SET v_message_body       = CONCAT('Your Username is: ', v_login_id);

                WHEN 'email' THEN

                    SET v_forgot_value       = v_email;
                    SET v_message_subject    = 'Your Registered Email';
                    SET v_message_body       = CONCAT('Your Registered Email is: ', v_email);

                WHEN 'phone' THEN

                    SET v_forgot_value       = v_phone;
                    SET v_message_subject    = 'Your Registered Phone Number';
                    SET v_message_body       = CONCAT('Your Registered Phone Number is: ', v_phone);

            END CASE;

            -- =========================
            -- Validate Recovery Destination
            -- =========================
            IF v_forgot_value IS NULL
            OR (pForgot = 'email' AND pContactType <> 'phone')
            OR (pForgot = 'phone' AND pContactType <> 'email')
            OR (pForgot = 'username' AND pContactType NOT IN ('email', 'phone'))
            OR (pContactType = 'email' AND (v_email IS NULL OR BINARY pDestination <> BINARY v_email))
            OR (pContactType = 'phone' AND (v_phone IS NULL OR BINARY pDestination <> BINARY v_phone)) THEN

                SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
                SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'Invalid recovery destination.');

                LEAVE main_block;
            END IF;

            -- =========================
            -- Generate Message GUID
            -- =========================
            CALL getSequence('OUTBOUND_MSGS.MESSAGE_GUID', 'MSG-', 5000, 'handleOtpSuccess SP', v_message_guid);

            -- =========================
            -- Prepare Outbound Message JSON
            -- =========================
            SET v_outbound_msgs_json = buildJSONSmart(v_outbound_msgs_json, 'message_guid',                     v_message_guid);
            SET v_outbound_msgs_json = buildJSONSmart(v_outbound_msgs_json, 'object_name',                      'FORGOT_LOGIN_ID');
            SET v_outbound_msgs_json = buildJSONSmart(v_outbound_msgs_json, 'business_context.forgot_type',     pForgot);
            SET v_outbound_msgs_json = buildJSONSmart(v_outbound_msgs_json, 'business_context.message_name',    CONCAT('Forgot ', pForgot));
            SET v_outbound_msgs_json = buildJSONSmart(v_outbound_msgs_json, 'business_context.notes',           CONCAT('Recovery of ', pForgot));
            SET v_outbound_msgs_json = buildJSONSmart(v_outbound_msgs_json, 'message_content.message_subject',  v_message_subject);
            SET v_outbound_msgs_json = buildJSONSmart(v_outbound_msgs_json, 'message_content.message_body',     v_message_body);
            SET v_outbound_msgs_json = buildJSONSmart(v_outbound_msgs_json, 'recipient_info.to_address',        pDestination);

            -- =========================
            -- Insert Outbound Message
            -- =========================
            INSERT INTO outbound_msgs
            SET     message_guid                    = v_message_guid,
                    parent_message_table_name       = 'customer',
                    parent_message_table_rec_id     = v_customer_rec_id,
                    object_name                     = 'FORGOT_LOGIN_ID',
                    current_status                  = 'PENDING',
                    outbound_msgs_json              = v_outbound_msgs_json,
                    row_metadata                    = v_row_metadata;

            SET v_outbound_msgs_rec_id = LAST_INSERT_ID();

            SET v_outbound_msgs_json = buildJSONSmart(v_outbound_msgs_json, 'outbound_messages_rec_id', v_outbound_msgs_rec_id);

            UPDATE  outbound_msgs
            SET     outbound_msgs_json              = v_outbound_msgs_json
            WHERE   outbound_msgs_rec_id            = v_outbound_msgs_rec_id;

            -- =========================
            -- Build Success Response
            -- =========================
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 0);
            SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'Account recovery information queued successfully.');

            -- =====================================================
            -- RESET PASSWORD
            -- =====================================================
            WHEN 'RESET PASSWORD' THEN

                SET v_reset_token = UUID();

                UPDATE  customer
                SET     customer_json = JSON_SET(customer_json,
                                            '$.otp_reset_token',    v_reset_token,
                                            '$.reset_token_expiry', NOW() + INTERVAL 10 MINUTE
                                        )
                WHERE   customer_rec_id = v_customer_rec_id;

                SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode',                           0);
                SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',                                'Reset token generated successfully');
                SET pjRespObj = buildJSONSmart(pjRespObj, 'jData.contents.reset_token',                     v_reset_token);
                SET pjRespObj = buildJSONSmart(pjRespObj, 'jData.contents.reset_token_expires_in_minutes',  10);

            -- =====================================================
            -- REGISTER (placeholder)
            -- =====================================================
            WHEN 'FORGOT PASSWORD' THEN

                SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 0);
                SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',      'OTP verified for Forgot password');

                -- =====================================================
            -- REGISTER (placeholder)
            -- =====================================================
            WHEN 'REGISTER' THEN

                SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 0);
                SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',      'OTP verified for registration');
            
           
            -- =====================================================
            -- LOGIN
            -- =====================================================
            WHEN 'LOGIN' THEN

                -- =========================
                -- Prepare Token Request
                -- =========================
                SET v_token_req_obj = getTemplate('reqResp');

                SET v_token_req_obj = buildJSONSmart(v_token_req_obj, 'jData.P_CUSTOMER_REC_ID', v_customer_rec_id);

                SET v_token_resp_obj = getTemplate('reqResp');

                -- =========================
                -- Generate User Auth Token
                -- =========================
                CALL generateUserAuthToken(v_token_req_obj, v_token_resp_obj);

                -- =========================
                -- Validate Token Response
                -- =========================
                IF COALESCE(getJval(v_token_resp_obj, 'jHeader.responseCode'), '1') <> '0' THEN

                    SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
                    SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', getJval(v_token_resp_obj, 'jHeader.message'));

                    LEAVE main_block;
                END IF;

                -- =========================
                -- Extract Generated Token
                -- =========================
                SET v_user_auth_token  = getJval(v_token_resp_obj, 'jData.user_auth_token');
                SET v_user_session_id  = getJval(v_token_resp_obj, 'jData.user_session_id');
                SET v_token_expires_at = getJval(v_token_resp_obj, 'jData.session_expires_at');

                -- =========================
                -- Get Customer JSON
                -- =========================
                SELECT  customer_json
                INTO    v_customer_json
                FROM    customer
                WHERE   customer_rec_id = v_customer_rec_id
                LIMIT   1;

                -- =========================
                -- Build Success Response
                -- =========================
                SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 0);
                SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message', 'LOGIN_SUCCESS - Login successful.');

                SET pjRespObj = buildJSONSmart(pjRespObj, 'jData.contents', v_customer_json);

                SET pjRespObj = buildJSONSmart(pjRespObj, 'jData.user_auth_token',   v_user_auth_token);
                SET pjRespObj = buildJSONSmart(pjRespObj, 'jData.user_session_id',   v_user_session_id);
                SET pjRespObj = buildJSONSmart(pjRespObj, 'jData.session_expires_at', v_token_expires_at);


            -- =====================================================
            -- DEFAULT
            -- =====================================================
            ELSE

                SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 1);
                SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',      'Invalid purpose');

        END CASE;

    END main_block;

END $$

DELIMITER ;

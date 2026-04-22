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
                                    OUT   pjRespObj		  JSON
								)
BEGIN

	DECLARE v_customer_rec_id   	INT;
    DECLARE v_login_id        	    VARCHAR(100);
	DECLARE v_email         	    VARCHAR(255);
    DECLARE v_phone         	    VARCHAR(20);
    DECLARE v_reset_token    	    VARCHAR(100);
    DECLARE v_message_guid          VARCHAR(100);
    DECLARE v_outbound_msgs_rec_id  INT;

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

        CALL getSequence('OUTBOUND_MSGS.MESSAGE_GUID','MSG-', 5000,'genOTP SP', v_message_guid);

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

                -- Set common fields for this purpose
                SET v_outbound_msgs_json = JSON_SET(v_outbound_msgs_json,
                                                '$.object_name',                        'FORGOT_LOGIN_ID',
                                                '$.business_context.message_name',      'Forgot Login ID',
                                                '$.business_context.notes',             'Login ID recovery',
                                                '$.message_content.message_subject',    'Your Login ID',
                                                '$.message_content.message_body',       CONCAT('Your Login ID is: ', v_login_id)
                                            );

                IF pContactType = 'loginid' THEN

                    -- Send to email if exists
                    IF v_email IS NOT NULL THEN

                        CALL getSequence('OUTBOUND_MSGS.MESSAGE_GUID', 'MSG-', 5000, 'handleOtpSuccess SP', v_message_guid);

                        -- Override channel-specific fields
                        SET v_outbound_msgs_json = JSON_SET(v_outbound_msgs_json,
                                                        '$.message_guid',                       v_message_guid,
                                                        '$.business_context.notes',             'Login ID recovery via email',
                                                        '$.recipient_info.to_address',          v_email,
                                                        '$.recipient_info.is_email_verified',   FALSE
                                                    );

                        INSERT INTO outbound_msgs
                        SET message_guid                = v_message_guid,
                            parent_message_table_name   = 'customer',
                            parent_message_table_rec_id = v_customer_rec_id,
                            object_name                 = 'FORGOT_LOGIN_ID',
                            current_status              = 'PENDING',
                            outbound_msgs_json          = v_outbound_msgs_json,
                            row_metadata                = v_row_metadata;

                        SET v_outbound_msgs_rec_id  = LAST_INSERT_ID();
                        SET v_outbound_msgs_json    = JSON_SET(v_outbound_msgs_json, '$.outbound_messages_rec_id', v_outbound_msgs_rec_id);

                        UPDATE outbound_msgs
                        SET    outbound_msgs_json   = v_outbound_msgs_json
                        WHERE  outbound_msgs_rec_id = v_outbound_msgs_rec_id;

                    END IF;

                    -- Send to phone if exists
                    IF v_phone IS NOT NULL THEN

                        CALL getSequence('OUTBOUND_MSGS.MESSAGE_GUID', 'MSG-', 5000, 'handleOtpSuccess SP', v_message_guid);

                        -- Override channel-specific fields
                        SET v_outbound_msgs_json = JSON_SET(v_outbound_msgs_json,
                                                        '$.message_guid',                       v_message_guid,
                                                        '$.business_context.notes',             'Login ID recovery via phone',
                                                        '$.recipient_info.to_address',          v_phone,
                                                        '$.recipient_info.is_email_verified',   NULL
                                                    );

                        INSERT INTO outbound_msgs
                        SET message_guid                = v_message_guid,
                            parent_message_table_name   = 'customer',
                            parent_message_table_rec_id = v_customer_rec_id,
                            object_name                 = 'FORGOT_LOGIN_ID',
                            current_status              = 'PENDING',
                            outbound_msgs_json          = v_outbound_msgs_json,
                            row_metadata                = v_row_metadata;

                        SET v_outbound_msgs_rec_id  = LAST_INSERT_ID();
                        SET v_outbound_msgs_json    = JSON_SET(v_outbound_msgs_json, '$.outbound_messages_rec_id', v_outbound_msgs_rec_id);

                        UPDATE outbound_msgs
                        SET    outbound_msgs_json   = v_outbound_msgs_json
                        WHERE  outbound_msgs_rec_id = v_outbound_msgs_rec_id;

                    END IF;

                ELSEIF pContactType = 'email' THEN

                    CALL getSequence('OUTBOUND_MSGS.MESSAGE_GUID', 'MSG-', 5000, 'handleOtpSuccess SP', v_message_guid);

                    -- Override channel-specific fields
                    SET v_outbound_msgs_json = JSON_SET(v_outbound_msgs_json,
                                                    '$.message_guid',                       v_message_guid,
                                                    '$.business_context.notes',             'Login ID recovery via email',
                                                    '$.recipient_info.to_address',          v_email,
                                                    '$.recipient_info.is_email_verified',   FALSE
                                                );

                    INSERT INTO outbound_msgs
                    SET message_guid                = v_message_guid,
                        parent_message_table_name   = 'customer',
                        parent_message_table_rec_id = v_customer_rec_id,
                        object_name                 = 'FORGOT_LOGIN_ID',
                        current_status              = 'PENDING',
                        outbound_msgs_json          = v_outbound_msgs_json,
                        row_metadata                = v_row_metadata;

                    SET v_outbound_msgs_rec_id  = LAST_INSERT_ID();
                    SET v_outbound_msgs_json    = JSON_SET(v_outbound_msgs_json, '$.outbound_messages_rec_id', v_outbound_msgs_rec_id);

                    UPDATE outbound_msgs
                    SET    outbound_msgs_json   = v_outbound_msgs_json
                    WHERE  outbound_msgs_rec_id = v_outbound_msgs_rec_id;

                ELSEIF pContactType = 'phone' THEN

                    CALL getSequence('OUTBOUND_MSGS.MESSAGE_GUID', 'MSG-', 5000, 'handleOtpSuccess SP', v_message_guid);

                    -- Override channel-specific fields
                    SET v_outbound_msgs_json = JSON_SET(v_outbound_msgs_json,
                                                    '$.message_guid',                       v_message_guid,
                                                    '$.business_context.notes',             'Login ID recovery via phone',
                                                    '$.recipient_info.to_address',          v_phone,
                                                    '$.recipient_info.is_email_verified',   NULL
                                                );

                    INSERT INTO outbound_msgs
                    SET message_guid                = v_message_guid,
                        parent_message_table_name   = 'customer',
                        parent_message_table_rec_id = v_customer_rec_id,
                        object_name                 = 'FORGOT_LOGIN_ID',
                        current_status              = 'PENDING',
                        outbound_msgs_json          = v_outbound_msgs_json,
                        row_metadata                = v_row_metadata;

                    SET v_outbound_msgs_rec_id  = LAST_INSERT_ID();
                    SET v_outbound_msgs_json    = JSON_SET(v_outbound_msgs_json, '$.outbound_messages_rec_id', v_outbound_msgs_rec_id);

                    UPDATE outbound_msgs
                    SET    outbound_msgs_json   = v_outbound_msgs_json
                    WHERE  outbound_msgs_rec_id = v_outbound_msgs_rec_id;

                END IF;

                SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 0);
                SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',      'Success - Login ID sent via outbound message');

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
            WHEN 'REGISTER' THEN

                SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.responseCode', 0);
                SET pjRespObj = buildJSONSmart(pjRespObj, 'jHeader.message',      'OTP verified for registration');

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

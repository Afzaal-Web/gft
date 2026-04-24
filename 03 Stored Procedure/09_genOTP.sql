-- ==================================================================================================
-- Procedure: 	genOtp
-- Purpose:   	Generate OTP and insert into otp table and outbound_message table
-- 				Handles resend automatically by generating a new OTP each time
-- ==================================================================================================

DROP PROCEDURE IF EXISTS genOtp;

DELIMITER $$

CREATE PROCEDURE genOtp(
						 IN  	pjReqObj 	JSON,
						 INOUT  pjRespObj 	JSON
					   )
BEGIN
    -- =========================
    -- Variable Declarations
    -- =========================
	DECLARE v_contact_type      	VARCHAR(20);
    DECLARE v_destination       	VARCHAR(255);
    DECLARE v_purpose           	TEXT;
    
    DECLARE v_otp                  	CHAR(6);
    DECLARE v_expiry               	DATETIME;
    DECLARE v_otp_rec_id           	INT;
    DECLARE v_outbound_msgs_rec_id 	INT;
    DECLARE v_message_guid         	VARCHAR(100);
    DECLARE v_last_sent_time       	DATETIME;
    
    DECLARE v_outbound_msgs_json   	JSON;
    DECLARE v_row_metadata         	JSON;

    -- =========================
    -- Extract Request Values
    -- =========================
    SET v_contact_type 	= getJval(pjReqObj, 	'jData.P_CONTACT_TYPE');
    SET v_destination  	= getJval(pjReqObj, 	'jData.P_DESTINATION');
    SET v_purpose      	= getJval(pjReqObj, 	'jData.P_PURPOSE');
    
    main_block: BEGIN
	-- =========================
    -- Basic Validation
    -- =========================
    IF v_contact_type IS NULL OR v_destination IS NULL OR v_purpose IS NULL THEN
		
        SET pjRespObj  = buildJSONSmart(pjRespObj,  'jHeader.responseCode',   1);
		SET pjRespObj  = buildJSONSmart(pjRespObj,  'jHeader.message',        'Missing required parameters');

        LEAVE main_block;
    END IF;
    
    -- =========================
    -- Cooldown check (e.g., 60 seconds)
    -- =========================
    SELECT MAX(created_at)
    INTO   v_last_sent_time
    FROM   otp
    WHERE  contact_type 	= v_contact_type
	AND    destination  	= v_destination
    AND    purpose      	= v_purpose;

    IF v_last_sent_time IS NOT NULL 
    AND TIMESTAMPDIFF(SECOND, v_last_sent_time, NOW()) < 60 THEN

		SET pjRespObj  = buildJSONSmart(pjRespObj,  'jHeader.responseCode',   				1);
		SET pjRespObj  = buildJSONSmart(pjRespObj,  'jHeader.message',        				'Please wait before requesting OTP again.');
		SET pjRespObj  = buildJSONSmart(pjRespObj,  'jData.contents.next_otp_in_secs',       60 - TIMESTAMPDIFF(SECOND, v_last_sent_time, NOW()));

        LEAVE main_block;
    END IF;

	
		-- =========================
		-- Expire previous OTPs (for resend)
		-- =========================
		UPDATE  otp
		SET 	expires_at 		= NOW(),
				otp_retries 	= 0
		WHERE   contact_type 	= v_contact_type
		AND 	destination  	= v_destination
		AND     purpose      	= v_purpose
		AND 	expires_at 		> NOW();

		-- =========================
		-- Generate new OTP
		-- =========================
		SET v_otp    = COALESCE(
                         getJval(pjReqObj, 'jData.P_PRESET_OTP'),
                         LPAD(FLOOR(100000 + RAND() * 900000), 6, '0')
                       );
					   
		SET v_expiry 	= DATE_ADD(NOW(), INTERVAL 5 MINUTE);
		
	   -- =========================
		-- Generate message guid number
		-- ========================= 
		CALL getSequence('OUTBOUND_MSGS.MESSAGE_GUID','MSG-', 5000,'genOTP SP', v_message_guid);

		-- =========================
		-- Insert OTP record
		-- =========================
		INSERT INTO otp
		SET contact_type      = v_contact_type,
			destination       = v_destination,
			otp_code          = v_otp,
			expires_at        = v_expiry,
			otp_retries       = 3,
			next_otp_in_secs  = 60,
			purpose			  = v_purpose;

		SET v_otp_rec_id 	  = LAST_INSERT_ID();

		-- =========================
		-- Prepare outbound_msgs JSON
		-- =========================
		SET v_outbound_msgs_json = getTemplate('outbound_msgs');

		SET v_outbound_msgs_json = JSON_SET(v_outbound_msgs_json,
											'$.message_guid',                   v_message_guid,
											'$.parent_message_table_name',      'otp',
											'$.parent_message_table_rec_id',    v_otp_rec_id,
											'$.object_name',                    'OTP',

											-- Business Context
											'$.business_context.module_name',   'AUTH',
											'$.business_context.message_name',
																				CASE 
																					WHEN v_contact_type = 'phone' THEN 'Verification of Phone Number'
																					WHEN v_contact_type = 'email' THEN 'Verification of Email'
																					ELSE 'OTP Verification'
																				END,
											'$.business_context.message_type',  'TRANSACTIONAL',
											'$.business_context.notes',          CONCAT('OTP for ', v_purpose),
											'$.business_context.login_id',       v_destination,

											-- Delivery Config
											'$.delivery_config.channel_number', 1,
											'$.delivery_config.priority_level', 1,
											'$.delivery_config.is_need_tracking', TRUE,

											-- Sender Info
											'$.sender_info.from_name',          'GFT',
											'$.sender_info.from_address',       'no-reply@gft.com',

											-- Recipient Info
											'$.recipient_info.to_address',      v_destination,
											'$.recipient_info.is_email_verified',
												IF(v_contact_type = 'email', FALSE, NULL),

											-- Message Content
											'$.message_content.message_subject', 'Your OTP Code',
											'$.message_content.message_body',
												CONCAT(
														'Your OTP is ', v_otp,
														'. It will expire in 5 minutes.',
														' Purpose: ', v_purpose
													),

											-- Scheduling
											'$.scheduling.scheduled_at',        NOW(),
											'$.scheduling.retry_interval',      60,

											-- Lifecycle Status
											'$.lifecycle_status.current_status', 'PENDING',
											'$.lifecycle_status.delivery_status', 'NOT_SENT',
											'$.lifecycle_status.send_attempts',  0,
											'$.lifecycle_status.number_of_retries', 3
										);

		-- =========================
		-- Row Metadata
		-- =========================
		SET v_row_metadata = getTemplate('row_metadata');

		SET v_row_metadata = JSON_SET(v_row_metadata,
									 '$.created_at', NOW(),
									 '$.created_by', 'SYSTEM'
									);

		-- =========================
		-- Insert outbound message
		-- =========================
		INSERT INTO outbound_msgs
		SET message_guid                	= v_message_guid,
			parent_message_table_name   	= 'otp',
			parent_message_table_rec_id 	= v_otp_rec_id,
			object_name                 	= 'OTP',
			current_status					= 'Pending',
			outbound_msgs_json         		= v_outbound_msgs_json,
			row_metadata                	= v_row_metadata;

		SET v_outbound_msgs_rec_id 			= LAST_INSERT_ID();

		-- Update JSON with generated PK
		SET v_outbound_msgs_json = JSON_SET( v_outbound_msgs_json,
											'$.outbound_messages_rec_id', v_outbound_msgs_rec_id
											);

		UPDATE  outbound_msgs
		SET 	outbound_msgs_json 	 = v_outbound_msgs_json
		WHERE 	outbound_msgs_rec_id = v_outbound_msgs_rec_id;
        
            -- =========================
    -- Success Response
    -- =========================

		SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.responseCode', 0);
	    SET pjRespObj = buildJSONSmart( pjRespObj,'jHeader.message', 'OTP has been sent to your verified contact.');  
    
    END main_block;
    
    -- insert into logs table

END $$

DELIMITER ;

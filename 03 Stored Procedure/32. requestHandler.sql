DROP PROCEDURE requestHandler;

DELIMITER $$

CREATE PROCEDURE requestHandler(
								  IN 	pClientIp 		varchar(45),
								  IN 	pAffNum 		varchar(16),
								  IN 	pAppName 		varchar(32),
								  IN 	pActionCode 	varchar(50),
								  IN 	pJsonRequest 	text,
								  OUT 	pJsonResponse text
							   )
BEGIN
  -- constants
  DECLARE vdStart 					timestamp 			DEFAULT 		CURRENT_TIMESTAMP;
  DECLARE vThisObj 					VARCHAR(32) 		DEFAULT 		'requestHandler';
  DECLARE vAccessToken 				VARCHAR(64) 		DEFAULT 		'fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03';
  DECLARE vAccessKey 				VARCHAR(64) 		DEFAULT 		'0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16';

  -- variables
  DECLARE vRespCode 				VARCHAR(8);
  DECLARE vRespMessage 				VARCHAR(255);
  DECLARE vLogReqStatus 			VARCHAR(32);
  DECLARE vLogFailReason 			VARCHAR(128);

  DECLARE vTemp 					VARCHAR(255);
  DECLARE viTemp 					integer;
  DECLARE vjTemp 					JSON;
  DECLARE vjReqObj 					JSON;
  DECLARE vjLogObj 					JSON;
  DECLARE vjResponse 				JSON 				DEFAULT getResponseTemplate();

  DECLARE vRequestId 				bigint;
  DECLARE vResponse 				json;
  DECLARE vAction 					varchar(50);
  DECLARE vResponseTime 			timestamp;
  DECLARE vDuration 				int;
  DECLARE vIsKnownAction 			boolean 			DEFAULT TRUE;
  DECLARE vFailureReason 			varchar(100) 		DEFAULT NULL;
  DECLARE vjTemp 					json;


  -- Exception handler
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    SET vResponseTime 	= NOW();
    SET vDuration 			= TIMESTAMPDIFF(SECOND, vdStart, vResponseTime);
    SET vFailureReason 	= 'unexpected_error';

    SET vjTemp 			= JSON_OBJECT('error', 					'*** Error ***: Unexpected error occurred',
										   'failure_reason', 		vFailureReason,
										   'action_code', 			pActionCode,
										   'client_ip', 			pClientIp,
										   'request_time', 			vdStart,
										   'response_time', 		vResponseTime,
										   'execution_duration', 	vDuration
                                           );

    UPDATE  activity_log
	SET 	json_response	 = vjTemp,
			response_time 	 = vResponseTime,
			failure_reason 	 = vFailureReason
    WHERE row_id 			 = vRequestId;

    RESIGNAL;
  END;

  -- --------------------------------------------------------------------------------------
  -- -----------------------------   Show Starts   ---------------------------------------- 

  IF vjResponse IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Response object is null';
  END IF;


  -- ---------------------------    House Keeping    -------------------------------------- 
  -- --------------------------------------------------------------------------------------

  SET vjLogObj	= 	buildJSON(NULL, 		 "loggingObject", 	vThisObj);
  SET vjLogObj	= 	buildJSON(vjLogObj, 	 "requestTime", 		vdStart);

  CALL debugLog(vThisObj, 'Create Temp Table');
    -- Create the temporary tables for static data
    -- CREATE TEMPORARY TABLE IF NOT EXISTS temp_IP_WhiteList AS       SELECT * FROM IP_WhiteList;

    -- --------------------------------------------------------------------------------------
    -- ----------------------- Perform validity checks   ------------------------------------ 
    -- --------------------------------------------------------------------------------------

    thisProc:BEGIN

    IF NOT isValidIP(pClientIp) THEN
      SET vTemp = CONCAT('Unauthorized hit. IP: ', pClientIp);
      CALL debugLog(vThisObj, vTemp);

      SET vjResponse 		= buildJSON(vjResponse, 'jHeader.responseCode', 1);
      SET vjResponse 		= buildJSON(vjResponse, 'jHeader.message', vTemp);

      SET vLogReqStatus 	= 'FAIL';
      SET vLogFailReason 	= vTemp;

      LEAVE thisProc;
    END IF;

    -- Validate request JSON 
    IF JSON_VALID(pJsonRequest) = 0 THEN
      SET vTemp = 'request is not a JSON object';

      SET vjResponse = buildJSON(vjResponse, 'jHeader.responseCode', 2);
      SET vjResponse = buildJSON(vjResponse, 'jHeader.message', vTemp);

      SET vLogReqStatus = 'FAIL';
      SET vLogFailReason = vTemp;

      CALL debugLog(vThisObj, vTemp);

      LEAVE thisProc;
    END IF;

  -- convert request to JSON object
    SET vjReqObj = CONVERT(p_json_request, json);

    IF 		STRCMP(getJKeyValue(vjReqObj, 'jHeader.accessToken'), 	vAccessToken) 	<> 0
		OR 	STRCMP(getJKeyValue(vjReqObj, 'jHeader.accessKey'), 	vAccessKey) 	<> 0 THEN

      SET vTemp 			= 'DB access credential are not valid: ';

      SET vjResponse 		= buildJSON(vjResponse, 'jHeader.responseCode', 3);
      SET vjResponse 		= buildJSON(vjResponse, 'jHeader.message', 		vTemp);

      SET vLogReqStatus 	= 'FAIL';
      SET vLogFailReason 	= vTemp;

      SET vTemp 			= CONCAT(vTemp, getJKeyValue(vjReqObj, 'jHeader.accessToken'), ' == ', vAccessToken,
							  ' <==> ',
							  getJKeyValue(vjReqObj, 'jHeader.accessKey'), 				   ' == ', vAccessKey);
      CALL debugLog(vThisObj, vTemp);

      LEAVE thisProc;
    END IF;

    -- TODO: check if parameter action code and json action code are the same or not. 


    -- --------------------------------------------------------------------------------------
    -- ----------------------- All is okay. Perform Action   -------------------------------- 
    -- --------------------------------------------------------------------------------------

    CALL debugLog(vThisObj, '----- All checks are okay. Execute the Action  -----');


    -- ---------------------------------------------------------
    --  Service: Common 
    -- ---------------------------------------------------------
    -- Process action_code for meta data
    CASE pActionCode
      WHEN 'CMN.S.GETVIEW' THEN

          -- Gets the entire json response doc 
          CALL debugLog(vThisObj, 'Calling getViewJSON');

          SET vjResponse = getViewJSON(getJKeyValue(vjReqObj, 'jData.PAPPNAME'),
						   getJKeyValue(vjReqObj, 'jData.P_VIEW_NAME'));

      --          SET vjResponse = buildJSON(vjResponse, 'jData', vjTemp);




      WHEN 'CMN.U.UPSERT_C ONTENT' 					THEN CALL upsert_content(pAffNum, pAppName, vjReqObj, vjResponse);

      WHEN 'CMN.D.DELETE_CONTENT' 					THEN CALL delete_content(pAffNum, pAppName, vjReqObj, vjResponse);

      WHEN 'CMN.S.VIEW_CONTENT' 					THEN CALL get_view_content(pAffNum, pAppName, vjReqObj, vjResponse);

      WHEN 'CMN.S.APP_CONTENT' 						THEN CALL get_app_content(pAffNum, pAppName, vjReqObj, vjResponse);

      WHEN 'CMN.S.FORGOT_PASSWORD_OTP' 				THEN CALL get_forgot_password_otp(vjReqObj, vjResponse);

      WHEN 'CMN.U.RESET_PASSWORD' 					THEN CALL reset_password(vjReqObj, vjResponse);

      WHEN 'CMN.U.UPDATE_PASSWORD' 					THEN CALL update_password(vjReqObj, vjResponse);

      WHEN 'CMN.S.GET_USERNAME' 					THEN CALL get_username_by_email_or_phone(vjReqObj, vjResponse);

      WHEN 'CMN.S.BASE_OFFICE_CONTACT_DETAILS' 		THEN CALL get_base_office_contact_details(vjReqObj, vjResponse);
            
      WHEN 'CMN.I.RATING' 							THEN CALL create_rating(vjReqObj, vjResponse);
      
      WHEN 'CMN.S.HEATMAP_COORDINATES' 				THEN CALL get_heat_map_coordinates(vjReqObj, vjResponse);

      WHEN 'CMN.request7'							THEN SET vAction = 'request5';
      
      ELSE SET vAction = 'request5';
    END CASE;


    CALL debugLog(vThisObj, 'Doing Switch for TRIP');

    -- ---------------------------------------------------------
    --  Service: Trip 
    -- ---------------------------------------------------------
    -- Process action_code for Trip
    CASE pActionCode
      WHEN 'TRP.S.TRIP_BY_ID' 					THEN CALL get_trip_by_id(pAffNum, pAppName, vjReqObj, vjResponse);

      WHEN 'TRP.S.TRIP_BY_NUMBER'				THEN CALL get_trip_by_number(pAffNum, pAppName, vjReqObj, vjResponse);

      WHEN 'TRP.S.TRIP_OFFER_IDS_BY_DRIVER_ID' 	THEN CALL get_trip_offer_ids_by_driver_id(vjReqObj, vjResponse);

      WHEN 'TRP.U.TRIP_STATUS' 					THEN CALL update_trip_status(pAffNum, pAppName, vjReqObj, vjResponse);

      WHEN 'TRP.I.NEW_TRIP' 					THEN CALL trip_db.new_trip(pAffNum, pAppName, vjReqObj, vjResponse);

      WHEN 'TRP.I.BID' 							THEN CALL create_trip_bid(vjReqObj, vjResponse);
      
      WHEN 'TRP.S.BIDS' 						THEN CALL get_trip_bids(vjReqObj, vjResponse);
      
      WHEN 'TRP.U.BID_STATUS' 					THEN CALL update_trip_bid_status(vjReqObj, vjResponse);

      WHEN 'TRP.U.CANCEL' 						THEN CALL cancel_trip(vjReqObj, vjResponse);

      WHEN 'TRP.U.TRIP_TYPE_PREFERENCE' 		THEN CALL update_trip_type_preference(pAffNum, pAppName, vjReqObj, vjResponse);

      WHEN 'TRP.U.TRIP_PREFERENCE' 				THEN CALL update_trip_preference(pAffNum, pAppName, vjReqObj, vjResponse);

      WHEN 'TRP.I.CUSTOMER_TRIP' 				THEN CALL create_customer_trip(pAffNum, pAppName, vjReqObj, vjResponse);

      WHEN 'TRP.U.CUSTOMER_TRIP' 				THEN CALL update_customer_trip(pAffNum, pAppName, vjReqObj, vjResponse);

      WHEN 'TRP.I.TRIP_OFFERS' 					THEN CALL save_trip_offers_in_driver_activity_logs(vjReqObj, vjResponse);

      WHEN 'TRP.I.CHAT' 						THEN CALL create_chat_message_in_trip(vjReqObj, vjResponse);
            
      WHEN 'TRP.S.CHAT' 						THEN CALL get_chat_messages_by_trip_rec_id(vjReqObj, vjResponse);

      WHEN 'TRP.S.GET_TRIP_DETAILS' 			THEN SET vAction = 'request5';
      
      ELSE SET vAction = 'request5';
    END CASE;

    CALL debugLog(vThisObj, 'Check if a procedure was sucessfully executed');

    -- ---------------------------------------------------------
    --  Service: Driver 
    -- ---------------------------------------------------------
    -- Process action_code for Trip
    CASE pActionCode

      WHEN 'DRV.I.DRIVER' 								THEN CALL create_driver(vjReqObj, vjResponse);
      WHEN 'DRV.D.DRIVER' 								THEN CALL delete_driver(vjReqObj, vjResponse);

      WHEN 'DRV.S.LOGIN_DRIVER'							THEN CALL login_driver(vjReqObj, vjResponse);

      WHEN 'DRV.S.DRIVER' 								THEN CALL get_driver(vjReqObj, vjResponse);

      WHEN 'DRV.U.ACTIVE_STATUS' 						THEN CALL update_driver_active_status(vjReqObj, vjResponse);

      WHEN 'DRV.I.DESIRED_DESTINATION' 					THEN CALL create_driver_desired_destination(vjReqObj, vjResponse);
      WHEN 'DRV.S.DESIRED_DESTINATIONS' 				THEN CALL get_driver_desired_destinations(vjReqObj, vjResponse);
      WHEN 'DRV.U.DESIRED_DESTINATION' 					THEN CALL update_driver_desired_destination(vjReqObj, vjResponse);
      WHEN 'DRV.D.DESIRED_DESTINATION' 					THEN CALL delete_driver_desired_destination(vjReqObj, vjResponse);

      WHEN 'DRV.U.SETTINGS' 							THEN CALL update_driver_settings(pAffNum, pAppName, vjReqObj, vjResponse);
      WHEN 'DRV.S.SETTINGS' 							THEN CALL get_driver_settings(vjReqObj, vjResponse);

      WHEN 'DRV.I.OTP_TO_PHONE_NUMBER' 					THEN CALL send_otp_to_phone_number(vjReqObj, vjResponse);
      WHEN 'DRV.S.TERMS_AND_CONDITIONS' 				THEN CALL get_terms_and_conditions(vjReqObj, vjResponse);
      WHEN 'DRV.S.DOCUMENT_STATUS_AND_ANALYTICS' 		THEN CALL get_driver_document_status_and_analytics(vjReqObj, vjResponse);
      WHEN 'DRV.S.WEB_NOTIFICATIONS' 					THEN CALL get_driver_web_notifications(vjReqObj, vjResponse);

      WHEN 'DRV.I.REPLY_TO_ACTIONABLE_NOTIFICATION' 	THEN CALL reply_to_actionable_notification(vjReqObj, vjResponse);
      WHEN 'DRV.U.MARK_NOTIFICATION_READ' 				THEN CALL mark_notification_read(vjReqObj, vjResponse);
      WHEN 'DRV.S.RIDE_SUMMARY_AND_WALLET_OVERVIEW' 	THEN CALL get_ride_summary_and_wallet_overview(vjReqObj, vjResponse);
      WHEN 'DRV.S.WEB_PROFILE' 							THEN CALL get_current_driver_web_profile(vjReqObj, vjResponse);
      WHEN 'DRV.S.WALLET_TRANSACTION_HISTORY' 			THEN CALL get_wallet_transaction_history(vjReqObj, vjResponse);

      WHEN 'DRV.S.TRIP_HISTORY' 						THEN CALL get_driver_trip_history(vjReqObj, vjResponse);
      WHEN 'DRV.S.TRIP_DETAILS_BY_TRIP_ID' 				THEN CALL get_trip_details_by_trip_id(vjReqObj, vjResponse);
      WHEN 'DRV.S.FLEET_AFFILIATION_STATUS' 			THEN CALL get_fleet_affiliation_status(vjReqObj, vjResponse);

      WHEN 'DRV.I.REPLY_TO_ACTION_REQUIRED_REQUEST' 	THEN CALL reply_to_action_required_request(vjReqObj, vjResponse);
      WHEN 'DRV.S.NEARBY_AFFILIATE_COMPANIES' 			THEN CALL get_nearby_affiliate_companies(vjReqObj, vjResponse);
      WHEN 'DRV.S.REQUIRED_DOCUMENTS_LIST' 				THEN CALL get_required_documents_list(vjReqObj, vjResponse);
      WHEN 'DRV.I.DRIVER_DOCUMENT' 						THEN CALL upload_driver_document(vjReqObj, vjResponse);

      WHEN 'DRV.S.UPLOADED_DOCUMENTS' 					THEN CALL get_driver_uploaded_documents(vjReqObj, vjResponse);
      WHEN 'DRV.S.EARNINGS_SUMMARY' 					THEN CALL get_earnings_summary(vjReqObj, vjResponse);
      WHEN 'DRV.S.EARNINGS_DETAIL' 						THEN CALL get_earnings_details(vjReqObj, vjResponse);
      WHEN 'DRV.S.EXPENSES_LIST' 						THEN CALL get_expenses_list(vjReqObj, vjResponse);

      WHEN 'DRV.S.DRIVER_PROFILE' 						THEN CALL get_user_profile(vjReqObj, vjResponse);
      WHEN 'DRV.D.DRIVER_PROFILE' 						THEN CALL delete_user_profile(vjReqObj, vjResponse);
      WHEN 'DRV.U.PERSONAL_INFORMATION' 				THEN CALL update_personal_information(vjReqObj, vjResponse);
      WHEN 'DRV.S.REGISTERED_VEHICLES' 					THEN CALL get_registered_vehicles(vjReqObj, vjResponse);

      WHEN 'DRV.S.VEHICLE_DOCUMENTS' 					THEN CALL get_vehicle_documents(vjReqObj, vjResponse);
      WHEN 'DRV.I.BACKUP_VEHICLE' 						THEN CALL add_backup_vehicle(vjReqObj, vjResponse);
      WHEN 'DRV.S.PERSONAL_RATINGS_AND_REVIEWS' 		THEN CALL get_personal_ratings_reviews(vjReqObj, vjResponse);
      WHEN 'DRV.S.NETWORK_SETTINGS' 					THEN CALL get_network_ratings(vjReqObj, vjResponse);

      WHEN 'DRV.S.BANK_DEPOSIT_HISTORY' 				THEN CALL get_bank_deposits_history(vjReqObj, vjResponse);
      WHEN 'DRV.S.LAST_DEPOSIT_SUMMARY' 				THEN CALL get_last_deposit_summary(vjReqObj, vjResponse);
      WHEN 'DRV.S.TRIP_DETAILS_BY_TRIP_NUMBER' 			THEN CALL get_trip_details_by_trip_number(vjReqObj, vjResponse);
      
      WHEN 'DRV.S.CUD_MANAGE_ADDITIONAL_CONTACTS' 		THEN CALL cud_manage_additional_contacts(vjReqObj, vjResponse);

      WHEN 'DRV.U.EXPENSES' 							THEN CALL upsert_driver_expenses(vjReqObj, vjResponse);

      WHEN 'DRV.I.SUBMIT_REQUEST_FOR_PRIMARY_VEHICLE_CHANGE' 		THEN CALL submit_request_for_primary_vehicle_change(vjReqObj, vjResponse);
      WHEN 'DRV.I.SUBMIT_REQUEST_FOR_ADDITIONAL_CHARGES' 			THEN CALL submit_request_for_additional_charges(vjReqObj, vjResponse);
      WHEN 'DRV.I.SUBMIT_REQUEST_FOR_UPDATE_DEPOSIT_INFORMATION' 	THEN CALL submit_request_for_update_deposit_information(vjReqObj, vjResponse);
      WHEN 'DRV.I.SUBMIT_REQUEST_FOR_UPDATE_LICENSE_INFORMATION' 	THEN CALL submit_request_for_update_license_information(vjReqObj, vjResponse);
      WHEN 'DRV.I.SUBMIT_REQUEST_FOR_REVIEW_UPLOADED_DOCUMENTS' 	THEN CALL submit_request_for_review_uploaded_documents(vjReqObj, vjResponse);
      WHEN 'DRV.I.SUBMIT_REQUEST_FOR_JOIN_FLEET' 					THEN CALL submit_request_for_join_fleet(vjReqObj, vjResponse);
      WHEN 'DRV.I.SUBMIT_REQUEST_FOR_REGISTRATION' 					THEN CALL submit_request_for_driver_registration(vjReqObj, vjResponse);
      WHEN 'DRV.I.SUBMIT_REQUEST_FOR_LOST_OR_FOUND_ITEM' 			THEN CALL submit_request_for_lost_or_found_item(vjReqObj, vjResponse);
      WHEN 'DRV.I.SUBMIT_REQUEST_FOR_WITHDRAWL' 					THEN CALL submit_request_for_withdrawal(vjReqObj, vjResponse);

      WHEN 'DRV.I.CURRENT_LOCATION' 								THEN CALL update_driver_current_location(vjReqObj, vjResponse);
            
      WHEN 'DRV.U.ETA' 												THEN CALL update_driver_eta(vjReqObj, vjResponse);

      WHEN 'action n' 												THEN SET vAction = 'request5';
      
      ELSE SET vAction = 'request5';
    END CASE;

    -- ---------------------------------------------------------
    --  Service: Customer 
    -- ---------------------------------------------------------
    -- Process action_code for Customer
    CASE pActionCode

      WHEN 'CUS.I.CUSTOMER' 					THEN CALL create_customer(vjReqObj, vjResponse);

      WHEN 'CUS.S.LOGIN_CUSTOMER'				THEN CALL login_customer(vjReqObj, vjResponse);

      WHEN 'CUS.S.CUSTOMER_BY_REC_ID' 			THEN CALL get_customer_by_customer_rec_id(vjReqObj, vjResponse);

      WHEN 'action n' 							THEN SET vAction = 'request5';
      
      ELSE SET vAction = 'request5';
    END CASE;


    CALL debugLog(vThisObj, 'Check if a procedure was sucessfully executed');

    -- ---------------------------------------------------------
    --  Catch unknown action code
    -- ---------------------------------------------------------
    IF getJKeyValue(vjResponse, 'jHeader.message') = 'default_error' THEN
      -- action code was NOT valid and none of the procedures were executed. 
      SET vTemp 		= CONCAT('----- Unknown Action Code is called.   -----: ', pActionCode);
      CALL debugLog(vThisObj, vTemp);

      SET vjResponse 	= buildJSON(vjResponse, 	'jHeader.responseCode', 4);
      SET vjResponse 	= buildJSON(vjResponse, 	'jHeader.message', vTemp);

      SET vLogReqStatus = 'FAIL';
      SET vLogFailReason = vTemp;

      LEAVE thisProc;
    END IF;


  -- ---------------------------------------------------------
  --           exit point of the procedure. 
  -- ---------------------------------------------------------
  END thisProc;

  -- Send response
  SET pJsonResponse = vjResponse;

  -- Log request and response
  SET vjLogObj 		= buildJSON(vjLogObj, 'reqeustStatus', 	vLogReqStatus);
  SET vjLogObj 		= buildJSON(vjLogObj, 'failReason',		vLogFailReason);
  SET vjLogObj 		= buildJSON(vjLogObj, 'procDuration',   TIMESTAMPDIFF(SECOND, NOW(), vdStart));
  CALL activityLog(vThisObj, pActionCode, 'End of logging object', vjLogObj);

  -- Temp: debug info
  CALL debugLog(vThisObj, CAST(vjResponse AS char));
  CALL debugLog(vThisObj, '----- PROC Ends  -----');
END $$
DELIMITER ;
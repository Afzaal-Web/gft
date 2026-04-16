DROP PROCEDURE requestHandler;

DELIMITER $$

CREATE PROCEDURE requestHandler (
                                    IN    pClientIp       VARCHAR(45),
                                    IN    pAppName        VARCHAR(32),
                                    IN    pActionCode     VARCHAR(50),
                                    IN    pJsonRequest    TEXT,
                                    OUT   pJsonResponse   TEXT
                                )
BEGIN
    -- constants
    DECLARE vdStart             DATETIME(3)               DEFAULT NOW(3);
    DECLARE vThisObj            VARCHAR(32)               DEFAULT 'requestHandler';
    DECLARE vAccessToken        VARCHAR(64)               DEFAULT 'fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03';
    DECLARE vAccessKey          VARCHAR(64)               DEFAULT '0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16';

    -- variables
    DECLARE vRespCode           VARCHAR(8);
    DECLARE vRespMessage        VARCHAR(255);
    DECLARE vLogReqStatus       VARCHAR(32);
    DECLARE vLogFailReason      VARCHAR(128);

    DECLARE vTemp               VARCHAR(255);
    DECLARE viTemp              INTEGER;
    DECLARE vjReqObj            JSON;
    DECLARE vjLogObj            JSON;
    DECLARE vjResponse          JSON                      DEFAULT getTemplate('reqResp');

    DECLARE vResponse           JSON;
    DECLARE vAction             VARCHAR(50);
    DECLARE vResponseTime       DATETIME(3);
    DECLARE vDuration           DECIMAL(10,3);   
    DECLARE vIsKnownAction      BOOLEAN                   DEFAULT TRUE;
    DECLARE vFailureReason      VARCHAR(100)              DEFAULT NULL;


    -- Exception handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET vResponseTime       = NOW(3);                                        
        SET vDuration           = TIMESTAMPDIFF(MICROSECOND, vdStart, vResponseTime) / 1000000.0;
        SET vFailureReason      = 'unexpected_error';

        SET vjLogObj            = buildJSONSmart(vjLogObj,  'failure_reason',   vFailureReason);
        SET vjLogObj            = buildJSONSmart(vjLogObj,  'action_code',      pActionCode);
        SET vjLogObj            = buildJSONSmart(vjLogObj,  'client_ip',        pClientIp);
        SET vjLogObj            = buildJSONSmart(vjLogObj,  'request_time',     vdStart);
        SET vjLogObj            = buildJSONSmart(vjLogObj,  'response_time',    vResponseTime);
        SET vjLogObj            = buildJSONSmart(vjLogObj,  'proc_duration',    vDuration);                                    

        CALL logActivity(vThisObj, vjLogObj);

        RESIGNAL;
    END;
    -- --------------------------------------------------------------------------------------
    -- -----------------------------   Show Starts   ----------------------------------------

    IF vjResponse IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Response object is null';
    END IF;

    -- ---------------------------    House Keeping    --------------------------------------
    -- --------------------------------------------------------------------------------------


    SET vjLogObj    = buildJSONSmart(null,       'logging_object',   vThisObj);

    SET vjLogObj    = buildJSONSmart(vjLogObj,   'action_code',    pActionCode);

    SET vjLogObj    = buildJSONSmart(vjLogObj,   'json_request',     pJsonRequest);
    SET vjLogObj    = buildJSONSmart(vjLogObj,   'request_time',     vdStart);

    SET vjLogObj    = buildJSONSmart(vjLogObj,   'app_name',         pAppName);
    SET vjLogObj    = buildJSONSmart(vjLogObj,   'user_id',          getJval(pJsonRequest, 'jData.P_ACCOUNT_NUM'));
    SET vjLogObj    = buildJSONSmart(vjLogObj,   'device_info',      getJval(pJsonRequest, 'jHeader.P_DEVICE_INFO'));
    SET vjLogObj    = buildJSONSmart(vjLogObj,   'client_ip',        pClientIp);
    SET vjLogObj    = buildJSONSmart(vjLogObj,   'latitude',         getJval(pJsonRequest, 'jHeader.P_LATITUDE'));
    SET vjLogObj    = buildJSONSmart(vjLogObj,   'longitude',        getJval(pJsonRequest, 'jHeader.P_LONGITUDE'));


    CALL debugLog(vThisObj, 'Create Temp Table');
    -- Create the temporary tables for static data
    -- CREATE TEMPORARY TABLE IF NOT EXISTS temp_IP_WhiteList AS       SELECT * FROM IP_WhiteList;

    -- --------------------------------------------------------------------------------------
    -- ----------------------- Perform validity checks   ------------------------------------
    -- --------------------------------------------------------------------------------------

    thisProc:BEGIN

        IF NOT isValidIP(pClientIp) THEN
            SET vTemp           = CONCAT('Unauthorized hit. IP: ', pClientIp);
            CALL debugLog(vThisObj, vTemp);

            SET vjResponse      = buildJSONSmart(vjResponse, 'jHeader.responseCode',    1);
            SET vjResponse      = buildJSONSmart(vjResponse, 'jHeader.message',         vTemp);

            SET vLogReqStatus   = 'FAIL';
            SET vLogFailReason  = vTemp;

            LEAVE thisProc;
        END IF;

        -- Validate request JSON
        IF JSON_VALID(pJsonRequest) = 0 THEN
            SET vTemp = 'request is not a JSON object';

            SET vjResponse      = buildJSONSmart(vjResponse, 'jHeader.responseCode',    2);
            SET vjResponse      = buildJSONSmart(vjResponse, 'jHeader.message',         vTemp);

            SET vLogReqStatus   = 'FAIL';
            SET vLogFailReason  = vTemp;

            CALL debugLog(vThisObj, vTemp);

            LEAVE thisProc;
        END IF;
 -- convert request to JSON object
    SET vjReqObj = CONVERT(pJsonRequest, JSON);

        IF      STRCMP(getJval(vjReqObj, 'jHeader.accessToken'),   vAccessToken)   <> 0
            OR  STRCMP(getJval(vjReqObj, 'jHeader.accessKey'),     vAccessKey)     <> 0 THEN

            SET vTemp           = 'DB access credential are not valid: ';

            SET vjResponse      = buildJSONSmart(vjResponse, 'jHeader.responseCode',    3);
            SET vjResponse      = buildJSONSmart(vjResponse, 'jHeader.message',         vTemp);

            SET vLogReqStatus   = 'FAIL';
            SET vLogFailReason  = vTemp;
            
            SET vTemp = CONCAT( vTemp,
                               getJval(vjReqObj, 'jHeader.accessToken'), ' == ', vAccessToken, ' <==> ',
                               getJval(vjReqObj, 'jHeader.accessKey'),   ' == ', vAccessKey
                             );
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
        

        -- Extract jData from request and set it as main request object for ease of use in procedures.
        SET vjReqObj = getJval(vjReqObj, 'jData');

        -- Process action_code for meta data
        CASE pActionCode

            WHEN 'somenameGETVIEW' THEN
                -- Gets the entire json response doc
                CALL debugLog(vThisObj, 'Calling getViewJSON');
                SET vjResponse = getViewJSON(
                                              getJval(vjReqObj, 'jData.PAPPNAME'),
                                              getJval(vjReqObj, 'jData.P_VIEW_NAME')
                                            );

        -- =====================================================
        -- CUSTOMER MODULE (CUS)
        -- =====================================================
        WHEN 'CUS.U.CUSTOMER'                THEN CALL upsertCustomer(vjReqObj, vjResponse);
        WHEN 'CUS.S.CUSTOMER'                THEN CALL getCustomer(vjReqObj, vjResponse);
        WHEN 'CUS.U.PREFERENCES'             THEN CALL savePreferences(vjReqObj, vjResponse);

        -- =====================================================
        -- AUTH / SECURITY MODULE (AUT)
        -- =====================================================
        WHEN 'AUT.S.LOGIN'                   THEN CALL loginCustomer(vjReqObj, vjResponse);
        WHEN 'AUT.S.AUTH'                    THEN CALL getAuth(vjReqObj, vjResponse);
        WHEN 'AUT.S.VERIFY_EXISTING_NUMBER'  THEN CALL verifiyExistingNumber(vjReqObj, vjResponse);

        WHEN 'AUT.I.OTP'                     THEN CALL genOtp(vjReqObj, vjResponse);
        WHEN 'AUT.S.VERIFY_OTP'              THEN CALL verifyOtp(vjReqObj, vjResponse);

        WHEN 'AUT.S.FORGOT_LOGIN_ID'         THEN CALL forgotLoginID(vjReqObj, vjResponse);
        WHEN 'AUT.S.FORGOT_PASSWORD_OTP'     THEN CALL forgotPassword(vjReqObj, vjResponse);

        WHEN 'AUT.U.RESET_PASSWORD'          THEN CALL resetPassword(vjReqObj, vjResponse);
        WHEN 'AUT.U.CHANGE_PASSWORD'         THEN CALL changePassword(vjReqObj, vjResponse);

        -- =====================================================
        -- WALLET MODULE (WLT)
        -- =====================================================
        WHEN 'WLT.I.CUSTOMER_WALLET'         THEN CALL createAcustomerWallet(vjReqObj, vjResponse);
        WHEN 'WLT.I.ACTIVITY'                THEN CALL wallet_activity(vjReqObj, vjResponse);
        WHEN 'WLT.S.WALLETS'                 THEN CALL getWallets(vjReqObj, vjResponse);

        -- =====================================================
        -- PRODUCT MODULE (PRD)
        -- =====================================================
        WHEN 'PRD.U.PRODUCT'                 THEN CALL upsertProduct(vjReqObj, vjResponse);
        WHEN 'PRD.S.PRODUCT'                 THEN CALL getProduct(vjReqObj, vjResponse);

        -- =====================================================
        -- INVENTORY MODULE (INV)
        -- =====================================================
        WHEN 'INV.U.INVENTORY'               THEN CALL upsertInventory(vjReqObj, vjResponse);
        WHEN 'INV.S.INVENTORY'               THEN CALL getInventory(vjReqObj, vjResponse);

        -- =====================================================
        -- TRANSACTION MODULE (TRN)
        -- =====================================================
        WHEN 'TRN.I.MONEY_TRANSACTION'       THEN CALL createMoneyTransaction(vjReqObj, vjResponse);
        WHEN 'TRN.U.MONEY_TRANSACTION'       THEN CALL updateMoneyTransaction(vjReqObj, vjResponse);
        WHEN 'TRN.S.MONEY_TRANSACTION'       THEN CALL getMoneyManager(vjReqObj, vjResponse);

        -- =====================================================
        -- FINANCE MODULE (FIN)
        -- =====================================================
        WHEN 'FIN.S.CREDIT_CARD'             THEN CALL getCreditCard(vjReqObj, vjResponse);
        WHEN 'FIN.S.RATES'                   THEN CALL getRates(vjReqObj, vjResponse);
        WHEN 'FIN.S.ACCOUNT_VERIFICATION'    THEN CALL verifyAccountNum(vjReqObj, vjResponse);

        -- =====================================================
        -- CALCULATOR / UTILITY MODULE (CAL)
        -- =====================================================
        WHEN 'CAL.S.EXCHANGE_METAL'          THEN CALL exchangeMetalCalculator(vjReqObj, vjResponse);
        WHEN 'CAL.S.METAL_TO_CASH'           THEN CALL metalToCashConverter(vjReqObj, vjResponse);

        -- =====================================================
        -- CONTENT MODULE (CNT)
        -- =====================================================
        WHEN 'CNT.S.NEWS'                    THEN CALL getNews(vjReqObj, vjResponse);
        WHEN 'CNT.S.PROMOTIONS'              THEN CALL getPromotions(vjReqObj, vjResponse);

        -- =====================================================
        -- MESSAGING MODULE (MSG)
        -- =====================================================
        WHEN 'MSG.I.OUTBOUND_QUEUE'          THEN CALL queueOutboundMessage(vjReqObj, vjResponse);

        -- =====================================================
        -- DOCUMENT MODULE (DOC)
        -- =====================================================
        WHEN 'DOC.U.MANAGEMENT'              THEN CALL documentManagment(vjReqObj, vjResponse);

        -- =====================================================
        -- ORDER MODULE (ORD)
        -- =====================================================
        WHEN 'ORD.I.BUY_ORDER'               THEN CALL createOrder(vjReqObj, vjResponse);
        WHEN 'ORD.S.BUY_ORDER'               THEN CALL getOrder(vjReqObj, vjResponse); 
        WHEN 'ORD.U.BUY_ORDER'               THEN CALL updateOrder(vjReqObj, vjResponse); -- not done yet
        WHEN 'ORD.D.BUY_ORDER'               THEN CALL deleteOrder(vjReqObj, vjResponse); -- not done yet

        WHEN 'ORD.I.SELL_ORDER'              THEN CALL createOrder(vjReqObj, vjResponse);
        WHEN 'ORD.S.SELL_ORDER'              THEN CALL getOrder(vjReqObj, vjResponse); 
        WHEN 'ORD.U.SELL_ORDER'              THEN CALL updateOrder(vjReqObj, vjResponse); -- not done yet
        WHEN 'ORD.D.SELL_ORDER'              THEN CALL deleteOrder(vjReqObj, vjResponse); -- not done yet

        WHEN 'ORD.I.EXCHANGE_ORDER'          THEN CALL createOrder(vjReqObj, vjResponse);
        WHEN 'ORD.S.EXCHANGE_ORDER'          THEN CALL getOrder(vjReqObj, vjResponse); 
        WHEN 'ORD.U.EXCHANGE_ORDER'          THEN CALL updateOrder(vjReqObj, vjResponse); -- not done yet
        WHEN 'ORD.D.EXCHANGE_ORDER'          THEN CALL deleteOrder(vjReqObj, vjResponse); -- not done yet

        WHEN 'ORD.I.REDEEM_ORDER'            THEN CALL createOrder(vjReqObj, vjResponse);
        WHEN 'ORD.S.REDEEM_ORDER'            THEN CALL getOrder(vjReqObj, vjResponse); 
        WHEN 'ORD.U.REDEEM_ORDER'            THEN CALL updateOrder(vjReqObj, vjResponse); -- not done yet
        WHEN 'ORD.D.REDEEM_ORDER'            THEN CALL deleteOrder(vjReqObj, vjResponse); -- not done yet

        -- =====================================================
        -- UNKNOWN ACTION
        -- =====================================================
        ELSE
            SET vAction = 'unknown_action';

    END CASE;


        -- ---------------------------------------------------------
        --  Catch unknown action code
        -- ---------------------------------------------------------
        IF getJval(vjResponse, 'jHeader.message') = 'default_error' THEN
            -- action code was NOT valid and none of the procedures were executed.
            SET vTemp = CONCAT('----- Unknown Action Code is called.   -----: ', pActionCode);
            CALL debugLog(vThisObj, vTemp);

            SET vjResponse      = buildJSONSmart(vjResponse, 'jHeader.responseCode',    4);
            SET vjResponse      = buildJSONSmart(vjResponse, 'jHeader.message',         vTemp);

            SET vLogReqStatus   = 'FAIL';
            SET vLogFailReason  = vTemp;

            LEAVE thisProc;
        END IF;


    -- ---------------------------------------------------------
    --           exit point of the procedure.
    -- ---------------------------------------------------------
    END thisProc;

    -- Send response
    SET pJsonResponse = vjResponse;

    -- Log request and response
    SET vResponseTime = NOW(3);
    SET vDuration     = TIMESTAMPDIFF(MICROSECOND, vdStart, vResponseTime) / 1000000.0;

    SET vjLogObj      = buildJSONSmart(vjLogObj, 'action_status',    COALESCE(vLogReqStatus, 'SUCCESS'));
    SET vjLogObj      = buildJSONSmart(vjLogObj, 'failure_reason',   COALESCE(vLogFailReason, getJval(vjResponse, 'jHeader.message')));

    SET vjLogObj      = buildJSONSmart(vjLogObj,  'json_response',    pJsonResponse);
    SET vjLogObj      = buildJSONSmart(vjLogObj, 'response_time',     vResponseTime);
    SET vjLogObj      = buildJSONSmart(vjLogObj, 'proc_duration',     vDuration);

    CALL logActivity(vThisObj, vjLogObj);

    -- Temp: debug info
    CALL debugLog(vThisObj, CAST(vjResponse AS CHAR));

    CALL debugLog(vThisObj, '----- PROC Ends  -----');
END $$
DELIMITER ;
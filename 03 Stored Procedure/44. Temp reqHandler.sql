DROP PROCEDURE IF EXISTS requestHandler;

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
    DECLARE vdStart             TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    DECLARE vThisObj            VARCHAR(32) DEFAULT 'requestHandler';
    DECLARE vAccessToken        VARCHAR(64) DEFAULT 'fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03';
    DECLARE vAccessKey          VARCHAR(64) DEFAULT '0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16';

    -- variables
    DECLARE vRespCode           VARCHAR(8);
    DECLARE vRespMessage        VARCHAR(255);
    DECLARE vLogReqStatus       VARCHAR(32) DEFAULT 'SUCCESS';
    DECLARE vLogFailReason      VARCHAR(128) DEFAULT NULL;

    DECLARE vTemp               VARCHAR(255);
    DECLARE viTemp              INTEGER;
    DECLARE vjTemp              JSON;
    DECLARE vjReqObj            JSON;
    DECLARE vjLogObj            JSON;
    DECLARE vjResponse          JSON DEFAULT getTemplate('reqResp');

    DECLARE vRequestId          BIGINT;
    DECLARE vResponseTime       TIMESTAMP;
    DECLARE vDuration           INT;
    DECLARE vFailureReason      VARCHAR(100) DEFAULT NULL;

    -- =========================================================
    -- Exception Handler
    -- =========================================================
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET vResponseTime  = NOW();
        SET vDuration      = TIMESTAMPDIFF(SECOND, vdStart, vResponseTime);
        SET vFailureReason = 'unexpected_error';

        SET vjTemp = JSON_OBJECT(
            'error',              '*** Error ***: Unexpected error occurred',
            'failure_reason',     vFailureReason,
            'action_code',        pActionCode,
            'client_ip',          pClientIp,
            'request_time',       vdStart,
            'response_time',      vResponseTime,
            'execution_duration', vDuration
        );

        UPDATE activity_log
        SET
            json_response   = vjTemp,
            response_time   = vResponseTime,
            duration_sec    = vDuration,
            status          = 'FAIL',
            failure_reason  = vFailureReason
        WHERE row_id = vRequestId;

        RESIGNAL;
    END;

    -- =========================================================
    -- Validate Template
    -- =========================================================
    IF vjResponse IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Response object is null';
    END IF;

    -- =========================================================
    -- Insert Activity Log Row FIRST
    -- =========================================================
    INSERT INTO activity_log (
        action_code,
        app_name,
        client_ip,
        json_request,
        request_time,
        status
    )
    VALUES (
        pActionCode,
        pAppName,
        pClientIp,
        pJsonRequest,
        vdStart,
        'PROCESSING'
    );

    SET vRequestId = LAST_INSERT_ID();

    -- =========================================================
    -- Main Processing Block
    -- =========================================================
    thisProc: BEGIN

        IF NOT isValidIP(pClientIp) THEN
            SET vTemp = CONCAT('Unauthorized hit. IP: ', pClientIp);

            SET vjResponse = buildJSONSmart(vjResponse, 'jHeader.responseCode', 1);
            SET vjResponse = buildJSONSmart(vjResponse, 'jHeader.message', vTemp);

            SET vLogReqStatus  = 'FAIL';
            SET vLogFailReason = vTemp;

            LEAVE thisProc;
        END IF;

        IF JSON_VALID(pJsonRequest) = 0 THEN
            SET vTemp = 'request is not a JSON object';

            SET vjResponse = buildJSONSmart(vjResponse, 'jHeader.responseCode', 2);
            SET vjResponse = buildJSONSmart(vjResponse, 'jHeader.message', vTemp);

            SET vLogReqStatus  = 'FAIL';
            SET vLogFailReason = vTemp;

            LEAVE thisProc;
        END IF;

        SET vjReqObj = CONVERT(pJsonRequest, JSON);

        IF STRCMP(getJval(vjReqObj, 'jHeader.accessToken'), vAccessToken) <> 0
        OR STRCMP(getJval(vjReqObj, 'jHeader.accessKey'), vAccessKey) <> 0 THEN

            SET vTemp = 'DB access credential are not valid';

            SET vjResponse = buildJSONSmart(vjResponse, 'jHeader.responseCode', 3);
            SET vjResponse = buildJSONSmart(vjResponse, 'jHeader.message', vTemp);

            SET vLogReqStatus  = 'FAIL';
            SET vLogFailReason = vTemp;

            LEAVE thisProc;
        END IF;

        -- Extract jData
        SET vjReqObj = getJval(vjReqObj, 'jData');

        -- =====================================================
        -- Action Router
        -- =====================================================
        CASE pActionCode

            WHEN 'upsertCustomer'          THEN CALL upsertCustomer(vjReqObj, vjResponse);
            WHEN 'createAcustomerWallet'   THEN CALL createAcustomerWallet(vjReqObj, vjResponse);
            WHEN 'wallet_activity'         THEN CALL wallet_activity(vjReqObj, vjResponse);
            WHEN 'upsertProduct'           THEN CALL upsertProduct(vjReqObj, vjResponse);
            WHEN 'upsertInventory'         THEN CALL upsertInventory(vjReqObj, vjResponse);
            WHEN 'createMoneyTransaction'  THEN CALL createMoneyTransaction(vjReqObj, vjResponse);
            WHEN 'updateMoneyTransaction'  THEN CALL updateMoneyTransaction(vjReqObj, vjResponse);
            WHEN 'verifyOtp'               THEN CALL verifyOtp(vjReqObj, vjResponse);
            WHEN 'loginCustomer'           THEN CALL loginCustomer(vjReqObj, vjResponse);
            WHEN 'getCustomer'             THEN CALL getCustomer(vjReqObj, vjResponse);
            WHEN 'getWallets'              THEN CALL getWallets(vjReqObj, vjResponse);
            WHEN 'createBuyOrder'          THEN CALL createBuyOrder(vjReqObj, vjResponse);
            WHEN 'createSellOrder'         THEN CALL createSellOrder(vjReqObj, vjResponse);
            WHEN 'createExchangeOrder'     THEN CALL createExchangeOrder(vjReqObj, vjResponse);
            WHEN 'createRedeemOrder'       THEN CALL createRedeemOrder(vjReqObj, vjResponse);

            ELSE
                SET vTemp = CONCAT('Unknown Action Code: ', pActionCode);

                SET vjResponse = buildJSONSmart(vjResponse, 'jHeader.responseCode', 4);
                SET vjResponse = buildJSONSmart(vjResponse, 'jHeader.message', vTemp);

                SET vLogReqStatus  = 'FAIL';
                SET vLogFailReason = vTemp;
        END CASE;

    END thisProc;

    -- =========================================================
    -- Final Response
    -- =========================================================
    SET pJsonResponse = vjResponse;

    SET vResponseTime = NOW();
    SET vDuration     = TIMESTAMPDIFF(SECOND, vdStart, vResponseTime);

    UPDATE activity_log
    SET
        json_response   = vjResponse,
        response_time   = vResponseTime,
        duration_sec    = vDuration,
        status          = vLogReqStatus,
        failure_reason  = vLogFailReason
    WHERE row_id = vRequestId;

    CALL debugLog(vThisObj, CAST(vjResponse AS CHAR));
    CALL debugLog(vThisObj, '----- PROC Ends -----');

END $$

DELIMITER ;
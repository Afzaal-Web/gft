DROP PROCEDURE IF EXISTS insertOrder;

DELIMITER $$
CREATE PROCEDURE insertOrder(
    IN  pjReqObj JSON,
    OUT psRespObj JSON
)
BEGIN
    DECLARE v_order_type VARCHAR(20);
    DECLARE v_err_msg VARCHAR(500);

    /* ===================== Error Handler ===================== */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET STACKED DIAGNOSTICS CONDITION 1 v_err_msg = MESSAGE_TEXT;
        SET psResObj = JSON_OBJECT(
            'status',       'error',
            'status_code',  '1',
            'message',      'Procedure failed',
            'system_error', v_err_msg
        );
    END;

    SET v_order_type = getJval(pjReqObj, 'order_type');

    IF v_order_type = 'Buy' THEN
        CALL createBuyOrder(pjReqObj, psResObj);
    ELSEIF v_order_type = 'Sell' THEN
        CALL createSellOrder(pjReqObj, psResObj);
    ELSEIF v_order_type = 'Exchange' THEN
        CALL createExchangeOrder(pjReqObj, psResObj);
    ELSEIF v_order_type = 'Redeem' THEN
        CALL createRedeemOrder(pjReqObj, psResObj);
    ELSE
        SET psResObj = JSON_OBJECT(
            'status', 'error',
            'status_code', '6',
            'message', 'Unknown order_type. Supported: Buy, Sell, Exchange, Redeem'
        );
    END IF;


END$$
DELIMITER ;

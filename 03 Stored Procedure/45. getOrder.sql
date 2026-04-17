-- ==================================================================================================
-- Procedure:   getOrder
-- Purpose:     get the json of order with queried account_number
-- ==================================================================================================

DROP PROCEDURE IF EXISTS getOrders;

DELIMITER $$

CREATE PROCEDURE getOrders(
                            IN    pjReqObj    JSON,
                            INOUT pjRespObj     JSON
                         )
BEGIN

    DECLARE v_account_num   VARCHAR(50);
    DECLARE v_orders_json   JSON;


    -- Extract input
    SET v_account_num = getJval(pjReqObj, 'jData.P_ACCOUNT_NUMBER');

    -- Get all orders as JSON array
    SELECT  JSON_ARRAYAGG(order_json)
    INTO    v_orders_json
    FROM    orders
    WHERE account_number = v_account_num;

    -- If no orders found
    IF v_orders_json IS NULL THEN

        SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.responseCode', 	1);
        SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.message', 		CONCAT('No orders found for this customer ', v_account_num));

    ELSE

        SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.responseCode', 	0);
        SET pjRespObj = buildJSONSmart( pjRespObj, 'jHeader.message', 		CONCAT('Orders retrieved successfully for ', v_account_num));
        SET pjRespObj = buildJSONSmart( pjRespObj, 'jData.contents', 		v_orders_json);

    END IF;

END $$

DELIMITER ;


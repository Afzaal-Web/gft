-- ==================================================================================================
-- Procedure:   getOrder
-- Purpose:     get the json of order with queried account_number
-- ==================================================================================================

DROP PROCEDURE IF EXISTS getOrders;

DELIMITER $$

CREATE PROCEDURE getOrders(
                            IN  pReqObj     JSON,
                            OUT pResObj     JSON
                         )
BEGIN

    DECLARE v_account_num   VARCHAR(50);
    DECLARE v_orders_json   JSON;

    DECLARE vResObj         JSON DEFAULT getTemplate('reqResp');

    SET pResObj = vResObj;

    -- Extract input
    SET v_account_num = getJval(pReqObj, 'P_ACCOUNT_NUMBER');

    -- Get all orders as JSON array
    SELECT  JSON_ARRAYAGG(order_json)
    INTO    v_orders_json
    FROM    orders
    WHERE account_number = v_account_num;

    -- If no orders found
    IF v_orders_json IS NULL THEN
        SET pResObj = JSON_SET( pResObj,
                                '$.jHeader.responseCode',           '1',
                                '$.jHeader.message',                'No orders found for this customer',
                                '$.jData.account_number',            v_account_num
                            );
    ELSE
        SET pResObj = JSON_SET( pResObj,
                                '$.jHeader.responseCode',           '0',
                                '$.jHeader.message',                'Orders retrieved successfully',
                                '$.jData.account_number',            v_account_num,
                                '$.jData.orders',                    v_orders_json
                            );
    END IF;

END $$

DELIMITER ;

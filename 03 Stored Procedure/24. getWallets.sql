-- ==================================================================================================
-- Procedure:   getWallets
-- Purpose:     Retrieve all wallets from customer_json stored in the 'customer' table
-- ==================================================================================================

DROP PROCEDURE IF EXISTS getWallets;
DELIMITER $$

CREATE PROCEDURE getWallets (
    IN  pReqObj JSON,
    OUT pResObj JSON
)
BEGIN

    DECLARE v_customer_rec_id INT;
    DECLARE v_customer_json   JSON;
    DECLARE v_wallets_json    JSON;

    main_block: BEGIN

        -- Extract customer_rec_id from request
        SET v_customer_rec_id = getJval(pReqObj, 'customer_rec_id');

        -- Fetch customer JSON
        CALL getCustomer(pReqObj, v_customer_json);
        
        SET v_customer_json = getJval(v_customer_json, 'customer');

        -- If customer not found
        IF v_customer_json IS NULL THEN
            SET pResObj = JSON_OBJECT(
                'status', 'error',
                'message', 'Customer does not exist',
                'customer_rec_id', v_customer_rec_id
            );
            LEAVE main_block;
        END IF;

        -- Extract wallets array from customer JSON (assuming 'wallets' key exists)
        SET v_wallets_json = getJval(v_customer_json, 'customer_wallets');

        -- If wallets key does not exist, return empty array
        IF v_wallets_json IS NULL THEN
			SET v_wallets_json = JSON_OBJECT(
											'Gold', 	 0,
											'Silver', 	 0,
											'Platinum',  0,
											'Cash', 	 0
										);
		END IF;


        -- Build response
        SET pResObj = JSON_OBJECT(
            'status', 'success',
            'message', 'Wallets retrieved successfully',
            'wallets', v_wallets_json
        );

    END main_block;

END $$

DELIMITER ;

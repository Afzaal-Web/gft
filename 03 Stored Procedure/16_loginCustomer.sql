-- ==================================================================================================
-- Procedure:   loginCustomer
-- Purpose:     Validate login credentials and return success/failure
-- ==================================================================================================

DROP PROCEDURE IF EXISTS loginCustomer;
DELIMITER $$

CREATE PROCEDURE loginCustomer(
                                IN  pReqObj  JSON,
                                OUT pResObj  JSON
                              )
BEGIN
    DECLARE v_login_id  		 	VARCHAR(255);
    DECLARE v_password   			VARCHAR(255);
    
    DECLARE v_customer_rec_id 		INT;
    DECLARE v_user_name       		VARCHAR(255);
    DECLARE v_email          		VARCHAR(255);
    DECLARE v_phone           		VARCHAR(20);
    DECLARE v_db_password     		VARCHAR(255);

    main_block: BEGIN

        -- =========================
        -- Extract values from JSON
        -- =========================
        SET v_login_id 		= getJval(pReqObj, 'P_LOGIN_ID');
        SET v_password 		= getJval(pReqObj, 'P_PASSWORD');

        -- Validate input
        IF v_login_id IS NULL OR v_password IS NULL THEN
            SET pResObj = JSON_OBJECT(
                'status',  'INVALID_REQUEST',
                'message', 'Login ID and Password are required.'
            );
            LEAVE main_block;
        END IF;

        -- =========================
        -- Find user and get password
        -- =========================
        SELECT c.customer_rec_id, c.user_name, c.email, c.phone, getJval(a.auth_json,'$.login_credentials.password') AS db_password
        INTO   v_customer_rec_id, v_user_name, v_email, v_phone, v_db_password
        FROM   auth a
        JOIN   customer c ON a.parent_table_rec_id = c.customer_rec_id
        WHERE  c.user_name = v_login_id
            OR c.email  = v_login_id
            OR c.phone  = v_login_id
        LIMIT 1;

        -- User not found
        IF v_customer_rec_id IS NULL THEN
            SET pResObj = JSON_OBJECT(
                'status',  'USER_NOT_FOUND',
                'message', 'No account matches the provided login ID.'
            );
            LEAVE main_block;
        END IF;

        -- =========================
        -- Validate password
        -- =========================
        IF SHA2(v_password,256) <> v_db_password THEN
            SET pResObj = JSON_OBJECT(
                'status', 'INVALID_PASSWORD',
                'message', 'The password is incorrect.'
            );
            LEAVE main_block;
        END IF;

        -- =========================
        -- Success response
        -- =========================
        SET pResObj = JSON_OBJECT(
            'status',  'LOGIN_SUCCESS',
            'message', 'Login successful.'
        );

    END main_block;

END $$

DELIMITER ;

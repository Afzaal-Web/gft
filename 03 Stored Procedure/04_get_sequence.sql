-- ==================================================================================================
-- Procedure: 	getSequence
-- Purpose: 		Generate a unique sequence number based on column name with support for:
	--         			Column-specific default prefix and starting number (using CASE)
	--         			Optional override of prefix
	--         			Optional override of starting number
	-- 					User-provided values always override column defaults
	-- 					Designed for reuse across multiple modules (accounts, orders, customers, etc.)

-- Parameters: 		IN psColumnName (logical identifier e.g. MAIN ACCOUNT / ORDER NUMBER),
--             		IN psPrefix (optional prefix override), IN psStartingNumber (optional starting number override),
--             		OUT psSequenceNumber (final generated sequence value)
--
-- ==================================================================================================

DELIMITER $$

CREATE PROCEDURE getSequence (
							IN  psColumnName       	VARCHAR(255),
							IN  psPrefix           	VARCHAR(255),
							IN  psStartingNumber   	INT,
                            IN  psRequestedBy		VARCHAR(255),
							OUT psSequenceNumber   	VARCHAR(255)
							)
BEGIN
    DECLARE v_prefix           	VARCHAR(255);
    DECLARE v_starting_number  	INT;
    DECLARE v_seq_id           	INT;
    
    DECLARE v_requested_by		VARCHAR(255);

    /* ==============================
       CASE Column-based
       ============================== */
    CASE psColumnName
        WHEN 'CUSTOMER.MAIN_ACCOUNT_NUM' THEN
            SET v_prefix 			= 'P-';
            SET v_starting_number 	= 500;

        WHEN 'ORDERS.ORDER_NUM' THEN
            SET v_prefix 			= 'ORD-';
            SET v_starting_number 	= 1000;

		WHEN 'EMPLOYEE.EMPLOYEE_NUM' THEN
            SET v_prefix 			= 'EMP-';
            SET v_starting_number 	= 2000;

        ELSE
            SET v_prefix 			= 'GEN-';
            SET v_starting_number 	= 1;
    END CASE;

    /* ==============================
       Override defaults
       ============================== */
    IF psPrefix IS NOT NULL AND psPrefix <> '' THEN
        SET v_prefix = psPrefix;
    END IF;

    IF psStartingNumber IS NOT NULL AND psStartingNumber > 0 THEN
        SET v_starting_number = psStartingNumber;
    END IF;
    
	/* ==============================
       Set default value for requested by
	============================== */
    IF psRequestedBy IS NULL OR psRequestedBy = '' THEN
        SET v_requested_by = 'SYSTEM';
    ELSE
        SET v_requested_by = psRequestedBy;
    END IF;

    /* ==============================
       Generate sequence
       ============================== */
	INSERT INTO seq_num
        SET column_name 		= psColumnName,
            sequence_value   	= 'TEMP',
            requested_by   		= v_requested_by;

		SET v_seq_id 			= LAST_INSERT_ID();

    /* ==============================
       Build final sequence
       ============================== */
    SET psSequenceNumber = CONCAT(v_prefix, v_starting_number + v_seq_id);
    
    /* ==============================
       Update stored sequence value
       ============================== */
    UPDATE seq_num
       SET sequence_value 	= psSequenceNumber
	   WHERE seq_rec_id = v_seq_id;
       
END$$

DELIMITER ;

-- -----------------------------------------------------------------


-- Test Script
CALL getSequence('CUSTOMER.MAIN_ACCOUNT_NUM',NULL, NULL,'creatCustomer', @seq);
select @seq;

CALL getSequence('ORDERS.ORDER_NUM',NULL, NULL,'ORDERS SP', @seq);
select @seq;

CALL getSequence('EMPLOYEE.EMPLOYEE_NUM',NULL, NULL,'EMPLOYEE SP', @seq);
select @seq;

CALL getSequence('order_num',NULL, NULL, @seq);
select @seq;

CALL getSequence('customer_num',NULL, NULL, @seq);
select @seq;

CALL getSequence('employee_num',NULL, NULL, @seq);
select @seq;




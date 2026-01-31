DELIMITER $$

CREATE TRIGGER after_update_customer
AFTER UPDATE
ON customer
FOR EACH ROW
BEGIN
    INSERT INTO update_logs
    SET table_name   		= 'customer',
        row_rec_id   		= OLD.customer_rec_id,
        prev_row_json		= OLD.customer_json,
        next_row_json		= NEW.customer_json,
        updated_at    		= NOW(); 
END $$

DELIMITER ;


SELECT TRIGGER_NAME, EVENT_MANIPULATION, EVENT_OBJECT_TABLE, ACTION_TIMING
FROM information_schema.TRIGGERS
WHERE TRIGGER_SCHEMA = DATABASE();

DROP TRIGGER after_delete_asset_rate_history;
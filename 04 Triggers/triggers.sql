-- ==================================================================================================
-- Procedure: create_audit_triggers
-- Purpose: Generate triggers for tables on update and delete
-- ==================================================================================================



-- ======================== FOR ASSET RATE HISTORY =============================


# update_trigger_sql
DELIMITER $$
CREATE TRIGGER after_update_asset_rate_history
AFTER UPDATE ON asset_rate_history
FOR EACH ROW
BEGIN

	  INSERT INTO row_audit_logs
	  SET table_name		= 'asset_rate_history',
		  row_rec_id		= OLD.asset_rate_rec_id,
		  prev_row_json		= OLD.asset_rate_history_json,
		  next_row_json		= NEW.asset_rate_history_json,
		  updated_at		= NOW();
		
END$$
DELIMITER ;

# delete_trigger_sql
DELIMITER $$
CREATE TRIGGER after_delete_asset_rate_history
AFTER DELETE ON asset_rate_history
FOR EACH ROW
BEGIN
	 
	  INSERT INTO row_audit_logs
	  SET table_name		= 'asset_rate_history',
		  row_rec_id		= OLD.asset_rate_rec_id,
		  prev_row_json		= OLD.asset_rate_history_json,
		  next_row_json		= NULL,
		  updated_at		= NOW();
		
END$$
DELIMITER ;


-- ======================== FOR AUTH =============================


# update_trigger_sql
DELIMITER $$
CREATE TRIGGER after_update_auth
AFTER UPDATE ON auth
FOR EACH ROW
BEGIN

	  INSERT INTO row_audit_logs
	  SET table_name		= 'auth',
		  row_rec_id		= OLD.auth_rec_id,
		  prev_row_json		= OLD.auth_json,
		  next_row_json		= NEW.auth_json,
		  updated_at		= NOW();
		
END$$
DELIMITER ;

# delete_trigger_sql
DELIMITER $$
CREATE TRIGGER after_delete_auth
AFTER DELETE ON auth
FOR EACH ROW
BEGIN
	 
	  INSERT INTO row_audit_logs
	  SET table_name		= 'auth',
		  row_rec_id		= OLD.auth_rec_id,
		  prev_row_json		= OLD.auth_json,
		  next_row_json		= NULL,
		  updated_at		= NOW();
		
END$$
DELIMITER ;


-- ======================== FOR CORPORATE ACCOUNT =============================



# update_trigger_sql
DELIMITER $$
CREATE TRIGGER after_update_corporate_account
AFTER UPDATE ON corporate_account
FOR EACH ROW
BEGIN

	  INSERT INTO row_audit_logs
	  SET table_name		= 'corporate_account',
		  row_rec_id		= OLD.corporate_account_rec_id,
		  prev_row_json		= OLD.corporate_account_json,
		  next_row_json		= NEW.corporate_account_json,
		  updated_at		= NOW();
		
END$$
DELIMITER ;

# delete_trigger_sql                
DELIMITER $$
CREATE TRIGGER after_delete_corporate_account
AFTER DELETE ON corporate_account
FOR EACH ROW
BEGIN
	 
	  INSERT INTO row_audit_logs
	  SET table_name		= 'corporate_account',
		  row_rec_id		= OLD.corporate_account_rec_id,
		  prev_row_json		= OLD.corporate_account_json,
		  next_row_json		= NULL,
		  updated_at		= NOW();
		
END$$
DELIMITER ;

-- ======================== FOR CUSTOMER =============================



# update_trigger_sql
DELIMITER $$
CREATE TRIGGER after_update_customer
AFTER UPDATE ON customer
FOR EACH ROW
BEGIN

	  INSERT INTO row_audit_logs
	  SET table_name		= 'customer',
		  row_rec_id		= OLD.customer_rec_id,
		  prev_row_json		= OLD.customer_json,
		  next_row_json		= NEW.customer_json,
		  updated_at		= NOW();
		
END$$
DELIMITER ;

# delete_trigger_sql
DELIMITER $$
CREATE TRIGGER after_delete_customer
AFTER DELETE ON customer
FOR EACH ROW
BEGIN
	 
	  INSERT INTO row_audit_logs
	  SET table_name		= 'customer',
		  row_rec_id		= OLD.customer_rec_id,
		  prev_row_json		= OLD.customer_json,
		  next_row_json		= NULL,
		  updated_at		= NOW();
		
END$$
DELIMITER ;

-- ======================== FOR PRODUCTS =============================


# update_trigger_sql
DELIMITER $$
CREATE TRIGGER after_update_products
AFTER UPDATE ON products
FOR EACH ROW
BEGIN

	  INSERT INTO row_audit_logs
	  SET table_name		= 'products',
		  row_rec_id		= OLD.product_rec_id,
		  prev_row_json		= OLD.products_json,
		  next_row_json		= NEW.products_json,
		  updated_at		= NOW();
		
END$$
DELIMITER ;

#  delete_trigger_sql
DELIMITER $$

CREATE TRIGGER after_delete_products
AFTER DELETE ON products
FOR EACH ROW
BEGIN
	 
	  INSERT INTO row_audit_logs
	  SET table_name		= 'products',
		  row_rec_id		= OLD.product_rec_id,
		  prev_row_json		= OLD.products_json,
		  next_row_json		= NULL,
		  updated_at		= NOW();
		
END$$
DELIMITER ;


-- ======================== FOR INVENTORY =============================


# update_trigger_sql
DELIMITER $$

CREATE TRIGGER after_update_inventory
AFTER UPDATE ON inventory
FOR EACH ROW
BEGIN

	  INSERT INTO row_audit_logs
	  SET table_name		= 'inventory',
		  row_rec_id		= OLD.inventory_rec_id,
		  prev_row_json		= OLD.inventory_json,
		  next_row_json		= NEW.inventory_json,
		  updated_at		= NOW();
		
END$$
DELIMITER ;

# delete_trigger_sql                
DELIMITER $$

CREATE TRIGGER after_delete_inventory
AFTER DELETE ON inventory
FOR EACH ROW
BEGIN
	 
	  INSERT INTO row_audit_logs
	  SET table_name		= 'inventory',
		  row_rec_id		= OLD.inventory_rec_id,
		  prev_row_json		= OLD.inventory_json,
		  next_row_json		= NULL,
		  updated_at		= NOW();
		
END$$
DELIMITER ;

-- ======================== FOR TRADABLE ASSETS =============================


# update_trigger_sql
DELIMITER $$

CREATE TRIGGER after_update_tradable_assets
AFTER UPDATE ON tradable_assets
FOR EACH ROW
BEGIN

	  INSERT INTO row_audit_logs
	  SET table_name		= 'tradable_assets',
		  row_rec_id		= OLD.tradable_assets_rec_id,
		  prev_row_json		= OLD.tradable_assets_json,
		  next_row_json		= NEW.tradable_assets_json,
		  updated_at		= NOW();
		
END$$
DELIMITER ;
                
# delete_trigger_sql                
DELIMITER $$

CREATE TRIGGER after_delete_tradable_assets
AFTER DELETE ON tradable_assets
FOR EACH ROW
BEGIN
	 
	  INSERT INTO row_audit_logs
	  SET table_name		= 'tradable_assets',
		  row_rec_id		= OLD.tradable_assets_rec_id,
		  prev_row_json		= OLD.tradable_assets_json,
		  next_row_json		= NULL,
		  updated_at		= NOW();
		
END$$
DELIMITER ;

-- ======================== FOR WALLET LEDGER =============================


# update_trigger_sql
DELIMITER $$

CREATE TRIGGER after_update_wallet_ledger
AFTER UPDATE ON wallet_ledger
FOR EACH ROW
BEGIN

	  INSERT INTO row_audit_logs
	  SET table_name		= 'wallet_ledger',
		  row_rec_id		= OLD.wallet_ledger_rec_id,
		  prev_row_json		= OLD.wallet_ledger_json,
		  next_row_json		= NEW.wallet_ledger_json,
		  updated_at		= NOW();
		
END$$
DELIMITER ;
                
# delete_trigger_sql
DELIMITER $$

CREATE TRIGGER after_delete_wallet_ledger
AFTER DELETE ON wallet_ledger
FOR EACH ROW
BEGIN
	 
	  INSERT INTO row_audit_logs
	  SET table_name		= 'wallet_ledger',
		  row_rec_id		= OLD.wallet_ledger_rec_id,
		  prev_row_json		= OLD.wallet_ledger_json,
		  next_row_json		= NULL,
		  updated_at		= NOW();
		
END$$
DELIMITER ;



# CHECK TOTAL TRIGGERS IN DB

SELECT TRIGGER_NAME, EVENT_MANIPULATION, EVENT_OBJECT_TABLE
FROM information_schema.TRIGGERS
WHERE TRIGGER_SCHEMA = DATABASE()
ORDER BY EVENT_OBJECT_TABLE;



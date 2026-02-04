-- ==================================================================================================
-- Procedure: create_audit_triggers
-- Purpose: Generate triggers for tables on update and delete
-- ==================================================================================================

DROP PROCEDURE generate_audit_triggers_sql;
DELIMITER $$

CREATE PROCEDURE generate_audit_triggers_sql(
    IN tbl_name VARCHAR(64),
    IN pk_col VARCHAR(64),
    IN json_col VARCHAR(64)
)
BEGIN

SELECT
		CONCAT(
				'DELIMITER $$
				
				CREATE TRIGGER after_update_', tbl_name, '
				AFTER UPDATE ON ', tbl_name, '
				FOR EACH ROW
				BEGIN
                
					  INSERT INTO row_audit_logs
                      SET table_name		= ''', tbl_name, ''',
						  row_rec_id		= OLD.', pk_col, ',
                          prev_row_json		= OLD.', json_col, ',
                          next_row_json		= NEW.', json_col, ',
                          updated_at		= NOW();
						
				END$$
				
				DELIMITER ;'
			) AS update_trigger_sql,

		CONCAT(
				'DELIMITER $$

				CREATE TRIGGER after_delete_', tbl_name, '
				AFTER DELETE ON ', tbl_name, '
				FOR EACH ROW
				BEGIN
					 
					  INSERT INTO row_audit_logs
                      SET table_name		= ''', tbl_name, ''',
						  row_rec_id		= OLD.', pk_col, ',
                          prev_row_json		= OLD.', json_col, ',
                          next_row_json		= NULL,
                          updated_at		= NOW();
						
				END$$

				DELIMITER ;'
			) AS delete_trigger_sql;

END$$
DELIMITER ;

SHOW TABLES;


-- ======================== FOR ASSET RATE HISTORY =============================

CALL generate_audit_triggers_sql('asset_rate_history', 'asset_rate_rec_id', 'asset_rate_history_json');

# update_trigger_sql
DELIMITER $$
CREATE TRIGGER after_update_asset_rate_history
AFTER UPDATE ON asset_rate_history
FOR EACH ROW
BEGIN

	  INSERT INTO update_logs
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
	 
	  INSERT INTO update_logs
	  SET table_name		= 'asset_rate_history',
		  row_rec_id		= OLD.asset_rate_rec_id,
		  prev_row_json		= OLD.asset_rate_history_json,
		  next_row_json		= NULL,
		  updated_at		= NOW();
		
END$$
DELIMITER ;


-- ======================== FOR AUTH =============================

CALL generate_audit_triggers_sql('auth', 'auth_rec_id', 'auth_json');

# update_trigger_sql
DELIMITER $$
CREATE TRIGGER after_update_auth
AFTER UPDATE ON auth
FOR EACH ROW
BEGIN

	  INSERT INTO update_logs
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
	 
	  INSERT INTO update_logs
	  SET table_name		= 'auth',
		  row_rec_id		= OLD.auth_rec_id,
		  prev_row_json		= OLD.auth_json,
		  next_row_json		= NULL,
		  updated_at		= NOW();
		
END$$
DELIMITER ;


-- ======================== FOR CORPORATE ACCOUNT =============================

CALL generate_audit_triggers_sql('corporate_account', 'corporate_account_rec_id', 'corporate_account_json');

# update_trigger_sql
DELIMITER $$
CREATE TRIGGER after_update_corporate_account
AFTER UPDATE ON corporate_account
FOR EACH ROW
BEGIN

	  INSERT INTO update_logs
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
	 
	  INSERT INTO update_logs
	  SET table_name		= 'corporate_account',
		  row_rec_id		= OLD.corporate_account_rec_id,
		  prev_row_json		= OLD.corporate_account_json,
		  next_row_json		= NULL,
		  updated_at		= NOW();
		
END$$
DELIMITER ;

-- ======================== FOR CUSTOMER =============================

CALL generate_audit_triggers_sql('customer','customer_rec_id','customer_json');

# update_trigger_sql
DELIMITER $$
CREATE TRIGGER after_update_customer
AFTER UPDATE ON customer
FOR EACH ROW
BEGIN

	  INSERT INTO update_logs
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
	 
	  INSERT INTO update_logs
	  SET table_name		= 'customer',
		  row_rec_id		= OLD.customer_rec_id,
		  prev_row_json		= OLD.customer_json,
		  next_row_json		= NULL,
		  updated_at		= NOW();
		
END$$
DELIMITER ;

-- ======================== FOR PRODUCTS =============================

CALL generate_audit_triggers_sql('products', 'product_rec_id', 'products_json');
# update_trigger_sql
DELIMITER $$
CREATE TRIGGER after_update_products
AFTER UPDATE ON products
FOR EACH ROW
BEGIN

	  INSERT INTO update_logs
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
	 
	  INSERT INTO update_logs
	  SET table_name		= 'products',
		  row_rec_id		= OLD.product_rec_id,
		  prev_row_json		= OLD.products_json,
		  next_row_json		= NULL,
		  updated_at		= NOW();
		
END$$
DELIMITER ;


-- ======================== FOR INVENTORY =============================

CALL generate_audit_triggers_sql('inventory', 'inventory_rec_id', 'inventory_json');

# update_trigger_sql
DELIMITER $$

CREATE TRIGGER after_update_inventory
AFTER UPDATE ON inventory
FOR EACH ROW
BEGIN

	  INSERT INTO update_logs
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
	 
	  INSERT INTO update_logs
	  SET table_name		= 'inventory',
		  row_rec_id		= OLD.inventory_rec_id,
		  prev_row_json		= OLD.inventory_json,
		  next_row_json		= NULL,
		  updated_at		= NOW();
		
END$$
DELIMITER ;

-- ======================== FOR TRADABLE ASSETS =============================

CALL generate_audit_triggers_sql('tradable_assets', 'tradable_assets_rec_id', 'tradable_assets_json');

# update_trigger_sql
DELIMITER $$

CREATE TRIGGER after_update_tradable_assets
AFTER UPDATE ON tradable_assets
FOR EACH ROW
BEGIN

	  INSERT INTO update_logs
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
	 
	  INSERT INTO update_logs
	  SET table_name		= 'tradable_assets',
		  row_rec_id		= OLD.tradable_assets_rec_id,
		  prev_row_json		= OLD.tradable_assets_json,
		  next_row_json		= NULL,
		  updated_at		= NOW();
		
END$$
DELIMITER ;

-- ======================== FOR WALLET LEDGER =============================

CALL generate_audit_triggers_sql('wallet_ledger', 'wallet_ledger_rec_id', 'wallet_ledger_json');

# update_trigger_sql
DELIMITER $$

CREATE TRIGGER after_update_wallet_ledger
AFTER UPDATE ON wallet_ledger
FOR EACH ROW
BEGIN

	  INSERT INTO update_logs
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
	 
	  INSERT INTO update_logs
	  SET table_name		= 'wallet_ledger',
		  row_rec_id		= OLD.wallet_ledger_rec_id,
		  prev_row_json		= OLD.wallet_ledger_json,
		  next_row_json		= NULL,
		  updated_at		= NOW();
		
END$$
DELIMITER ;

-- ======================== FOR MONEY MANAGER =============================

CALL generate_audit_triggers_sql('money_manager', 'money_manager_rec_id', 'money_manager_json');

# update_trigger_sql
DELIMITER $$

CREATE TRIGGER after_update_money_manager
AFTER UPDATE ON money_manager
FOR EACH ROW
BEGIN

	  INSERT INTO update_logs
	  SET table_name		= 'money_manager',
		  row_rec_id		= OLD.money_manager_rec_id,
		  prev_row_json		= OLD.money_manager_json,
		  next_row_json		= NEW.money_manager_json,
		  updated_at		= NOW();
		
END$$
				
DELIMITER ;

# delete_trigger_sql
DELIMITER $$

CREATE TRIGGER after_delete_money_manager
AFTER DELETE ON money_manager
FOR EACH ROW
BEGIN
	 
	  INSERT INTO update_logs
	  SET table_name		= 'money_manager',
		  row_rec_id		= OLD.money_manager_rec_id,
		  prev_row_json		= OLD.money_manager_json,
		  next_row_json		= NULL,
		  updated_at		= NOW();
		
END$$

DELIMITER ;

-- ======================== FOR CREDIT_CARD =============================

CALL generate_audit_triggers_sql('credit_card', 'credit_card_rec_id', 'credit_card_json');

# update_trigger_sql
DELIMITER $$

CREATE TRIGGER after_update_credit_card
AFTER UPDATE ON credit_card
FOR EACH ROW
BEGIN

	  INSERT INTO update_logs
	  SET table_name		= 'credit_card',
		  row_rec_id		= OLD.credit_card_rec_id,
		  prev_row_json		= OLD.credit_card_json,
		  next_row_json		= NEW.credit_card_json,
		  updated_at		= NOW();
		
END$$

DELIMITER ;

# delete_trigger_sql
DELIMITER $$

CREATE TRIGGER after_delete_credit_card
AFTER DELETE ON credit_card
FOR EACH ROW
BEGIN
	 
	  INSERT INTO update_logs
	  SET table_name		= 'credit_card',
		  row_rec_id		= OLD.credit_card_rec_id,
		  prev_row_json		= OLD.credit_card_json,
		  next_row_json		= NULL,
		  updated_at		= NOW();
		
END$$

DELIMITER ;






# CHECK TOTAL TRIGGERS IN DB

SELECT TRIGGER_NAME, EVENT_MANIPULATION, EVENT_OBJECT_TABLE
FROM information_schema.TRIGGERS
WHERE TRIGGER_SCHEMA = DATABASE()
ORDER BY EVENT_OBJECT_TABLE;



-- ===============================================
-- Enable inserting 0 into AUTO_INCREMENT
-- ===============================================
SET SESSION sql_mode='NO_AUTO_VALUE_ON_ZERO';

DROP TABLE IF EXISTS products;
-- ===============================================
-- Create product table
-- ===============================================
CREATE TABLE IF NOT EXISTS products (
    product_rec_id              INT 			PRIMARY KEY AUTO_INCREMENT,
    tradable_assets_rec_id      INT,
    asset_code               	VARCHAR(50),
    product_code				VARCHAR(100),
    product_type				VARCHAR(255),
    product_name                VARCHAR(255),

    products_json                JSON,
    row_metadata                JSON
);

ALTER TABLE products
ADD UNIQUE KEY unique_asset_product (asset_code, product_code);

-- ===============================================
-- Demo row product_rec_id : = 0
-- ===============================================

INSERT INTO products
SET
    product_rec_id              = 0,
    tradable_assets_rec_id      = 0,
    asset_code                  = 'GLD',
    product_code                = 'PG-2323',
    product_type                = 'Bar',
    product_name                = 'Gold Bar 10g',

	products_json				= castJson('products'),
    row_metadata				= castJson('row_metadata');

-- ===============================================
-- Product table ended
-- ===============================================

DROP TABLE IF EXISTS inventory;
-- ===============================================
-- Create inventory table
-- ===============================================
CREATE TABLE IF NOT EXISTS inventory (
    inventory_rec_id            INT 		PRIMARY KEY AUTO_INCREMENT,
    product_rec_id              INT,
    item_name                   VARCHAR(255),
    item_type                   VARCHAR(255),
    asset_type                  VARCHAR(255),
    availability_status         VARCHAR(255),

    inventory_json              JSON,
    row_metadata                JSON
);

-- ===============================================
-- Demo row inventory_rec_id : = 0
-- ===============================================

INSERT INTO inventory
SET
    inventory_rec_id            = 0,
    product_rec_id              = 0,
    item_name                   = 'Gold Bar - 1000g',
    item_type                   = 'Bar',
    asset_type                  = 'Gold',
    availability_status         = 'Available',

	inventory_json				= castJson('inventory'),
    row_metadata				= castJson('row_metadata');
-- ===============================================
-- Inventory table ended
-- ===============================================

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
    item_code                   varchar(255),
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
    item_code                   = 'GLD-241212',
    item_type                   = 'Bar',
    asset_type                  = 'Gold',
    availability_status         = 'Available',

	inventory_json				= castJson('inventory'),
    row_metadata				= castJson('row_metadata');
-- ===============================================
-- Inventory table ended
-- ===============================================


-- ===================================================
-- Sample Row
-- ===================================================

SET @inv = '{
  "sold_to": [
    {
      "taxes": 2.5,
      "sold_date": "2026-04-01",
      "metal_rate": 72.0,
      "order_date": "2026-04-01",
      "sold_to_id": 601,
      "weight_sold": 0.02,
      "order_number": "ORD-2001",
      "sold_to_name": "Ahmed Raza",
      "sold_to_email": "ahmed.raza@email.com",
      "sold_to_phone": "+923112223334",
      "making_charges": 15.0,
      "receipt_number": "SR-2001",
      "premium_charged": 8.0,
      "sold_to_address": "Lahore",
      "taxes_description": "GST",
      "total_price_charged": 180.0,
      "transaction_details": {
        "fee_type": "percentage",
        "fee_value": 2.0,
        "fee_currency": "PKR",
        "fee_description": "Platform fee",
        "transaction_num": "TXN-888999",
        "transaction_status": "Completed"
      }
    }
  ],
  "item_Size": "Ring Size 18",
  "item_code": "GLD-RNG-1001",
  "item_name": "Gold Ring Classic",
  "item_type": "Ring",
  "asset_type": "Gold",
  "net_weight": 8.5,
  "item_quality": "22K",
  "media_library": [
    {
      "media_url": "/media/inventory/gold_ring.png",
      "media_type": "image",
      "is_featured": true
    }
  ],
  "purchase_from": {
    "from_name": "Karachi Gold Market",
    "packaging": "Box Packed",
    "from_email": "supplier@goldmarket.com",
    "from_phone": "+923000000000",
    "metal_rate": 68.0,
    "from_address": "Karachi, Pakistan",
    "metal_weight": 8.5,
    "premium_paid": 12.0,
    "receipt_date": "2026-03-20",
    "purchase_date": "2026-03-20",
    "making_charges": 20.0,
    "receipt_number": "RCPT-9900",
    "total_tax_paid": 5.0,
    "mode_of_payment": "Cash",
    "tax_description": "Local tax",
    "total_price_paid": 620.0,
    "purchase_from_rec_id": 45,
    "check_or_transaction_no": "TXN-112233"
  },
  "product_rec_id": 101,
  "available_weight": 8.48,
  "inventory_rec_id": 501,
  "location_details": "Showroom Display - Lahore",
  "manufacturer_info": {
    "dimensions": "2cm diameter",
    "serial_number": "RNG-22K-0001",
    "manufacturer_name": "Almas Jewellers",
    "manufacturing_date": "2026-02-15",
    "manufacturing_country": "Pakistan",
    "serial_verification_url": "https://verify.jewellery.com/RNG-22K-0001",
    "serial_verification_text": "Verified"
  },
  "ownership_metrics": {
    "weight_sold_so_far": 0.02,
    "number_of_shareholders": 1,
    "number_of_transactions": 1
  },
  "weight_adjustment": 0.02,
  "availability_status": "Available",
  "pricing_adjustments": {
    "Discount": 1.0,
    "Promotions": "Eid Offer",
    "item_margin_adjustment": 2.5
  }
}';

INSERT INTO inventory
SET
    product_rec_id      = 101,
    item_name           = 'Gold Ring Classic',
    item_code           = 'GLD-RNG-1001',
    item_type           = 'Ring',
    asset_type          = 'Gold',
    availability_status = 'Available',

    inventory_json      = CAST(@inv AS JSON),
    row_metadata        = castJson('row_metadata');



SET @inv = '{
  "sold_to": [
    {
      "taxes": 3.0,
      "sold_date": "2026-04-02",
      "metal_rate": 74.0,
      "order_date": "2026-04-02",
      "sold_to_id": 701,
      "weight_sold": 0.05,
      "order_number": "ORD-3001",
      "sold_to_name": "Usman Ali",
      "sold_to_email": "usman.ali@email.com",
      "sold_to_phone": "+923221234567",
      "making_charges": 25.0,
      "receipt_number": "SR-3001",
      "premium_charged": 12.0,
      "sold_to_address": "Islamabad",
      "taxes_description": "GST",
      "total_price_charged": 420.0,
      "transaction_details": {
        "fee_type": "percentage",
        "fee_value": 2.5,
        "fee_currency": "PKR",
        "fee_description": "Platform fee",
        "transaction_num": "TXN-999111",
        "transaction_status": "Completed"
      }
    }
  ],
  "item_Size": "22 inches",
  "item_code": "GLD-CHN-2001",
  "item_name": "Gold Premium Chain",
  "item_type": "Chain",
  "asset_type": "Gold",
  "net_weight": 25.0,
  "item_quality": "22K",
  "media_library": [
    {
      "media_url": "/media/inventory/gold_chain.png",
      "media_type": "image",
      "is_featured": true
    }
  ],
  "purchase_from": {
    "from_name": "Lahore Gold Center",
    "packaging": "Luxury Box",
    "from_email": "supplier@lahoregold.com",
    "from_phone": "+923334445556",
    "metal_rate": 70.0,
    "from_address": "Lahore, Pakistan",
    "metal_weight": 25.0,
    "premium_paid": 20.0,
    "receipt_date": "2026-03-25",
    "purchase_date": "2026-03-25",
    "making_charges": 40.0,
    "receipt_number": "RCPT-1200",
    "total_tax_paid": 8.0,
    "mode_of_payment": "Bank Transfer",
    "tax_description": "Import + Local tax",
    "total_price_paid": 1750.0,
    "purchase_from_rec_id": 55,
    "check_or_transaction_no": "TXN-445566"
  },
  "product_rec_id": 201,
  "available_weight": 24.95,
  "inventory_rec_id": 0,
  "location_details": "Premium Display - Islamabad",
  "manufacturer_info": {
    "dimensions": "22 inches length",
    "serial_number": "CHN-22K-0001",
    "manufacturer_name": "Royal Jewellers",
    "manufacturing_date": "2026-02-20",
    "manufacturing_country": "Pakistan",
    "serial_verification_url": "https://verify.jewellery.com/CHN-22K-0001",
    "serial_verification_text": "Verified"
  },
  "ownership_metrics": {
    "weight_sold_so_far": 0.05,
    "number_of_shareholders": 1,
    "number_of_transactions": 1
  },
  "weight_adjustment": 0.05,
  "availability_status": "Available",
  "pricing_adjustments": {
    "Discount": 1.5,
    "Promotions": "Wedding Season Offer",
    "item_margin_adjustment": 3.0
  }
}';

INSERT INTO inventory
SET
    product_rec_id      = 201,
    item_name           = 'Gold Premium Chain',
    item_code           = 'GLD-CHN-2001',
    item_type           = 'Chain',
    asset_type          = 'Gold',
    availability_status = 'Available',

    inventory_json      = CAST(@inv AS JSON),
    row_metadata        = castJson('row_metadata');


  SET @inv_silver = '{
  "sold_to": [
    {
      "taxes": 1.8,
      "sold_date": "2026-04-02",
      "metal_rate": 125.0,
      "order_date": "2026-04-02",
      "sold_to_id": 602,
      "weight_sold": 0.05,
      "order_number": "ORD-3001",
      "sold_to_name": "Ali Khan",
      "sold_to_email": "ali.khan@email.com",
      "sold_to_phone": "+923001112233",
      "making_charges": 10.0,
      "receipt_number": "SR-3001",
      "premium_charged": 5.0,
      "sold_to_address": "Karachi",
      "taxes_description": "GST",
      "total_price_charged": 250.0,
      "transaction_details": {
        "fee_type": "percentage",
        "fee_value": 1.5,
        "fee_currency": "PKR",
        "fee_description": "Platform fee",
        "transaction_num": "TXN-555111",
        "transaction_status": "Completed"
      }
    }
  ],
  "item_Size": "Ring Size 20",
  "item_code": "SLV-241212",
  "item_name": "Silver Bar Classic",
  "item_type": "Bar",
  "asset_type": "Silver",
  "net_weight": 10.0,
  "item_quality": "925",
  "media_library": [
    {
      "media_url": "/media/inventory/silver_ring.png",
      "media_type": "image",
      "is_featured": true
    }
  ],
  "purchase_from": {
    "from_name": "Lahore Silver Market",
    "packaging": "Box Packed",
    "from_email": "supplier@silvermarket.com",
    "from_phone": "+923111111111",
    "metal_rate": 120.0,
    "from_address": "Lahore, Pakistan",
    "metal_weight": 10.0,
    "premium_paid": 8.0,
    "receipt_date": "2026-03-22",
    "purchase_date": "2026-03-22",
    "making_charges": 12.0,
    "receipt_number": "RCPT-8800",
    "total_tax_paid": 3.5,
    "mode_of_payment": "Cash",
    "tax_description": "Local tax",
    "total_price_paid": 400.0,
    "purchase_from_rec_id": 46,
    "check_or_transaction_no": "TXN-445566"
  },
  "product_rec_id": 102,
  "available_weight": 9.95,
  "inventory_rec_id": 502,
  "location_details": "Showroom Display - Karachi",
  "manufacturer_info": {
    "dimensions": "2.2cm diameter",
    "serial_number": "RNG-SLV-0002",
    "manufacturer_name": "Silver Craft Ltd",
    "manufacturing_date": "2026-02-20",
    "manufacturing_country": "Pakistan",
    "serial_verification_url": "https://verify.jewellery.com/RNG-SLV-0002",
    "serial_verification_text": "Verified"
  },
  "ownership_metrics": {
    "weight_sold_so_far": 0.05,
    "number_of_shareholders": 1,
    "number_of_transactions": 1
  },
  "weight_adjustment": 0.05,
  "availability_status": "Available",
  "pricing_adjustments": {
    "Discount": 0.5,
    "Promotions": "Spring Sale",
    "item_margin_adjustment": 1.5
  }
}';

INSERT INTO inventory
SET
    product_rec_id      = 102,
    item_name           = 'Silver Bar Classic',
    item_code           = 'SLV-241212',
    item_type           = 'Bar',
    asset_type          = 'Silver',
    availability_status = 'Available',
    inventory_json      = CAST(@inv_silver AS JSON),
    row_metadata        = castJson('row_metadata');



SET @inv_platinum = '{
  "sold_to": [
    {
      "taxes": 3.5,
      "sold_date": "2026-04-03",
      "metal_rate": 3100.0,
      "order_date": "2026-04-03",
      "sold_to_id": 603,
      "weight_sold": 0.01,
      "order_number": "ORD-4001",
      "sold_to_name": "Usman Sheikh",
      "sold_to_email": "usman.sheikh@email.com",
      "sold_to_phone": "+923223334455",
      "making_charges": 25.0,
      "receipt_number": "SR-4001",
      "premium_charged": 15.0,
      "sold_to_address": "Islamabad",
      "taxes_description": "GST",
      "total_price_charged": 500.0,
      "transaction_details": {
        "fee_type": "percentage",
        "fee_value": 2.5,
        "fee_currency": "PKR",
        "fee_description": "Platform fee",
        "transaction_num": "TXN-999777",
        "transaction_status": "Completed"
      }
    }
  ],
  "item_Size": "Ring Size 17",
  "item_code": "PLT-241212",
  "item_name": "Platinum Bar Classic",
  "item_type": "Bar",
  "asset_type": "Platinum",
  "net_weight": 5.0,
  "item_quality": "950",
  "media_library": [
    {
      "media_url": "/media/inventory/platinum_ring.png",
      "media_type": "image",
      "is_featured": true
    }
  ],
  "purchase_from": {
    "from_name": "Islamabad Platinum Hub",
    "packaging": "Premium Box",
    "from_email": "supplier@platinumhub.com",
    "from_phone": "+923333333333",
    "metal_rate": 3000.0,
    "from_address": "Islamabad, Pakistan",
    "metal_weight": 5.0,
    "premium_paid": 20.0,
    "receipt_date": "2026-03-25",
    "purchase_date": "2026-03-25",
    "making_charges": 30.0,
    "receipt_number": "RCPT-7700",
    "total_tax_paid": 10.0,
    "mode_of_payment": "Bank Transfer",
    "tax_description": "Import tax",
    "total_price_paid": 15500.0,
    "purchase_from_rec_id": 47,
    "check_or_transaction_no": "TXN-778899"
  },
  "product_rec_id": 103,
  "available_weight": 4.99,
  "inventory_rec_id": 503,
  "location_details": "Premium Vault - Islamabad",
  "manufacturer_info": {
    "dimensions": "2cm diameter",
    "serial_number": "RNG-PLT-0003",
    "manufacturer_name": "Platinum Works",
    "manufacturing_date": "2026-02-25",
    "manufacturing_country": "UAE",
    "serial_verification_url": "https://verify.jewellery.com/RNG-PLT-0003",
    "serial_verification_text": "Verified"
  },
  "ownership_metrics": {
    "weight_sold_so_far": 0.01,
    "number_of_shareholders": 1,
    "number_of_transactions": 1
  },
  "weight_adjustment": 0.01,
  "availability_status": "Available",
  "pricing_adjustments": {
    "Discount": 2.0,
    "Promotions": "Luxury Offer",
    "item_margin_adjustment": 3.0
  }
}';

INSERT INTO inventory
SET
    product_rec_id      = 103,
    item_name           = 'Platinum Bar Classic',
    item_code           = 'PLT-241212',
    item_type           = 'Bar',
    asset_type          = 'Platinum',
    availability_status = 'Available',
    inventory_json      = CAST(@inv_platinum AS JSON),
    row_metadata        = castJson('row_metadata');
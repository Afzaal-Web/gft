-- ==================================================================================================
-- Test Script: upsertInventory via requestHandler
-- Covers: INSERT (2 items) + UPDATE + Validation/Error cases
-- ==================================================================================================


-- ==================================================================================================
-- TEST 1: INSERT - Gold Bar 50g Inventory Item
-- ==================================================================================================

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jMetaData": {
    "page": 1,
    "limit": 10
  },
  "jData": {
    "P_ACTION_CODE":         "INV.I.INVENTORY",
    "P_APP_NAME":            "Gft-Product-App",

    "P_PRODUCT_CODE":        "P-GOLD-50G",
    "P_ASSET_CODE":          "GLD",
    "P_ASSET_TYPE":          "Metal",
    "P_PRODUCT_TYPE":        "commodity",

    "P_ITEM_NAME":           "Gold Bar 50g",
    "P_ITEM_CODE":           "INV-GOLD-50G-001",
    "P_ITEM_TYPE":           "Bar",
    "P_AVAILABILITY_STATUS": "available",

    "P_ITEM_SIZE":           "50g",
    "P_WEIGHT_ADJUSTMENT":   0.00,
    "P_NET_WEIGHT":          50.00,
    "P_AVAILABLE_WEIGHT":    50.00,
    "P_ITEM_QUALITY":        "999.9",
    "P_LOCATION_DETAILS":    "Vault A - Shelf 3",

    "P_PRICING_ADJUSTMENTS": {
      "item_margin_adjustment": 2.5,
      "Discount":               0.00,
      "Promotions":             "New Year Offer"
    },

    "P_MEDIA_LIBRARY": [
      {
        "media_type":  "image",
        "media_url":   "https://cdn.example.com/inventory/gold_bar_50g.jpg",
        "is_featured": true
      }
    ],

    "P_OWNERSHIP_METRICS": {
      "weight_sold_so_far":     0,
      "number_of_shareholders": 0,
      "number_of_transactions": 0
    },

    "P_MANUFACTURER_INFO": {
      "manufacturing_country":    "Switzerland",
      "manufacturer_name":        "PAMP",
      "manufacturing_date":       "2025-01-10",
      "serial_number":            "GB50-99221",
      "serial_verification_url":  "https://verify.pamp.com/GB50-99221",
      "serial_verification_text": "Verified",
      "dimensions":               "60x30x5 mm"
    },

    "P_PURCHASE_FROM": {
      "purchase_from_rec_id":    101,
      "receipt_number":          "RCPT-99211",
      "receipt_date":            "2025-01-12",
      "from_name":               "Global Bullion Traders",
      "from_address":            "Dubai Gold Souk",
      "from_phone":              "+971501234567",
      "from_email":              "sales@gbt.ae",
      "purchase_date":           "2025-01-12",
      "packaging":               "sealed",
      "metal_rate":              7200.50,
      "metal_weight":            50,
      "making_charges":          0,
      "premium_paid":            120,
      "total_tax_paid":          90,
      "tax_description":         "Import VAT",
      "total_price_paid":        361000,
      "mode_of_payment":         "bank_transfer",
      "check_or_transaction_no": "TXN88221"
    }
  }
}';

CALL requestHandler("127.0.0.1", "Gft-Product-App", "INV.I.INVENTORY", @reqObj, @pjRespObj);
SELECT @pjRespObj AS 'TEST 1 - INSERT Gold Bar 50g Inventory';


-- ==================================================================================================
-- TEST 2: INSERT - Silver Ring 10g Inventory Item (with sold_to)
-- ==================================================================================================

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jMetaData": {
    "page": 1,
    "limit": 10
  },
  "jData": {
    "P_ACTION_CODE":         "INV.I.INVENTORY",
    "P_APP_NAME":            "Gft-Product-App",

    "P_PRODUCT_CODE":        "P-SILVER-1KG",
    "P_ASSET_CODE":          "SILVER-001",
    "P_ASSET_TYPE":          "Metal",
    "P_PRODUCT_TYPE":        "commodity",

    "P_ITEM_NAME":           "Silver Ring 10g",
    "P_ITEM_CODE":           "INV-SILVER-RING-001",
    "P_ITEM_TYPE":           "Ring",
    "P_AVAILABILITY_STATUS": "out of stock",

    "P_ITEM_SIZE":           "10g",
    "P_WEIGHT_ADJUSTMENT":   0.10,
    "P_NET_WEIGHT":          9.90,
    "P_AVAILABLE_WEIGHT":    0,
    "P_ITEM_QUALITY":        "925",
    "P_LOCATION_DETAILS":    "Showroom Counter 2",

    "P_PRICING_ADJUSTMENTS": {
      "item_margin_adjustment": 5,
      "Discount":               3,
      "Promotions":             "Festival Sale"
    },

    "P_MEDIA_LIBRARY": [
      {
        "media_type":  "image",
        "media_url":   "https://cdn.example.com/inventory/silver_ring.jpg",
        "is_featured": true
      }
    ],

    "P_OWNERSHIP_METRICS": {
      "weight_sold_so_far":     10,
      "number_of_shareholders":  1,
      "number_of_transactions":  1
    },

    "P_MANUFACTURER_INFO": {
      "manufacturing_country":    "India",
      "manufacturer_name":        "Tanishq",
      "manufacturing_date":       "2024-12-01",
      "serial_number":            "SR10-44112",
      "serial_verification_url":  "https://verify.tanishq.com/SR10-44112",
      "serial_verification_text": "Verified",
      "dimensions":               "22mm diameter"
    },

    "P_PURCHASE_FROM": {
      "purchase_from_rec_id":    221,
      "receipt_number":          "RCPT-55110",
      "receipt_date":            "2024-12-05",
      "from_name":               "Mumbai Metals Ltd",
      "from_address":            "Zaveri Bazaar, Mumbai",
      "from_phone":              "+919811223344",
      "from_email":              "sales@mumbaimetals.in",
      "purchase_date":           "2024-12-05",
      "packaging":               "retail box",
      "metal_rate":              85.75,
      "metal_weight":            10,
      "making_charges":          15,
      "premium_paid":            5,
      "total_tax_paid":          12,
      "tax_description":         "GST",
      "total_price_paid":        890,
      "mode_of_payment":         "card",
      "check_or_transaction_no": "TXN77882"
    },

    "P_SOLD_TO": [
      {
        "order_date":            "2025-01-18",
        "order_number":          "ORD-7712",
        "receipt_number":        "RCP-7712",
        "sold_date":             "2025-01-18",
        "sold_to_id":             501,
        "sold_to_name":          "Ali Raza",
        "sold_to_phone":         "+923001234567",
        "sold_to_email":         "ali.raza@email.com",
        "sold_to_address":       "Lahore, Pakistan",
        "metal_rate":             92.50,
        "weight_sold":            10,
        "making_charges":         15,
        "premium_charged":        5,
        "taxes":                  12,
        "taxes_description":     "GST",
        "total_price_charged":    890,
        "transaction_details": {
          "transaction_num":      "TRX-55112",
          "fee_type":             "gateway",
          "fee_value":             2.5,
          "fee_currency":         "PKR",
          "fee_description":      "Card processing fee",
          "transaction_status":   "completed"
        }
      }
    ]
  }
}';

CALL requestHandler("127.0.0.1", "Gft-Product-App", "INV.I.INVENTORY", @reqObj, @pjRespObj);
SELECT @pjRespObj AS 'TEST 2 - INSERT Silver Ring 10g Inventory';


-- ==================================================================================================
-- TEST 3: UPDATE - Gold Bar 50g (change availability_status + location)
-- ==================================================================================================

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jMetaData": {
    "page": 1,
    "limit": 10
  },
  "jData": {
    "P_ACTION_CODE":         "INV.U.INVENTORY",
    "P_APP_NAME":            "Gft-Product-App",

    "P_INVENTORY_REC_ID":    1,
    "P_PRODUCT_CODE":        "P-GOLD-50G",
    "P_ASSET_CODE":          "GOLD-001",
    "P_ASSET_TYPE":          "Metal",
    "P_PRODUCT_TYPE":        "commodity",

    "P_ITEM_NAME":           "Gold Bar 50g",
    "P_ITEM_CODE":           "INV-GOLD-50G-001",
    "P_ITEM_TYPE":           "Bar",
    "P_AVAILABILITY_STATUS": "reserved",
    "P_LOCATION_DETAILS":    "Vault B - Shelf 1"
  }
}';

CALL requestHandler("127.0.0.1", "Gft-Product-App", "INV.U.INVENTORY", @reqObj, @pjRespObj);
SELECT @pjRespObj AS 'TEST 3 - UPDATE Gold Bar availability_status to reserved';


-- ==================================================================================================
-- TEST 4: ERROR - INSERT missing all required fields
-- ==================================================================================================

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jMetaData": {
    "page": 1,
    "limit": 10
  },
  "jData": {
    "P_ACTION_CODE":  "INV.I.INVENTORY",
    "P_APP_NAME":     "Gft-Product-App",
    "P_PRODUCT_CODE": "P-GOLD-50G"
  }
}';

CALL requestHandler("127.0.0.1", "Gft-Product-App", "INV.I.INVENTORY", @reqObj, @pjRespObj);
SELECT @pjRespObj AS 'TEST 4 - ERROR Missing item_name, item_type, availability_status (expect 3 errors)';


-- ==================================================================================================
-- TEST 5: ERROR - UPDATE with non-existent inventory_rec_id
-- ==================================================================================================

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jMetaData": {
    "page": 1,
    "limit": 10
  },
  "jData": {
    "P_ACTION_CODE":         "INV.U.INVENTORY",
    "P_APP_NAME":            "Gft-Product-App",

    "P_INVENTORY_REC_ID":    9999,
    "P_PRODUCT_CODE":        "P-GOLD-50G",
    "P_ASSET_CODE":          "GOLD-001",
    "P_ITEM_NAME":           "Ghost Item",
    "P_ITEM_CODE":           "INV-GHOST-001",
    "P_ITEM_TYPE":           "Bar",
    "P_ASSET_TYPE":          "Metal",
    "P_PRODUCT_TYPE":        "commodity",
    "P_AVAILABILITY_STATUS": "available"
  }
}';

CALL requestHandler("127.0.0.1", "Gft-Product-App", "INV.U.INVENTORY", @reqObj, @pjRespObj);
SELECT @pjRespObj AS 'TEST 5 - ERROR UPDATE non-existent inventory_rec_id (expect responseCode 1)';
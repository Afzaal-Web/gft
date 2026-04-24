-- ==================================================================================================
-- Test Script: upsertProduct via requestHandler
-- Covers: INSERT (3 products) + UPDATE + Validation/Error cases
-- ==================================================================================================


-- ==================================================================================================
-- TEST 1: INSERT - Gold Bar 50g
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
    "P_ACTION_CODE":            "PRD.U.PRODUCT",
    "P_APP_NAME":               "Gft-Product-App",

    "P_ASSET_CODE":             "GLD",
    "P_PRODUCT_CODE":           "P-GOLD-50G",
    "P_PRODUCT_TYPE":           "commodity",
    "P_PRODUCT_NAME":           "24K Gold Bar 50g",

    "P_PRODUCT_SHORT_NAME":     "Gold Bar 50g",
    "P_PRODUCT_DESCRIPTION":    "High purity 24 karat gold bar for trading.",
    "P_PRODUCT_CLASSIFICATION": "precious_metals",
    "P_ASSET_TYPE":             "physical",
    "P_PRODUCT_QUALITY":        "24K",

    "P_APPROXIMATE_WEIGHT":     50,
    "P_WEIGHT_UNIT":            "grams",
    "P_DIMENSIONS":             "8cm x 4cm x 0.4cm",

    "P_IS_PHYSICAL":            true,
    "P_IS_SLICEABLE":           false,

    "P_STANDARD_PRICE":         360000,
    "P_STANDARD_PREMIUM":       8000,
    "P_PRICE_CURRENCY":         "PKR",

    "P_APPLICABLE_TAXES": [
      {
        "tax_name":         "Sales Tax",
        "taxes_description":"Government sales tax",
        "amount":            17,
        "fixed_or_percent": "percent"
      }
    ],

    "P_QUANTITY_ON_HAND":       180,
    "P_MINIMUM_ORDER_QUANTITY": 1,
    "P_TOTAL_SOLD":             0,

    "P_OFFER_TO_CUSTOMER":      true,
    "P_DISPLAY_ORDER":          1,
    "P_ALERT_ON_LOW_STOCK":     15,

    "P_MEDIA_LIBRARY": [
      { "media_type": "image", "media_url": "https://cdn.example.com/gold50_front.jpg", "is_featured": true  },
      { "media_type": "image", "media_url": "https://cdn.example.com/gold50_back.jpg",  "is_featured": false },
      { "media_type": "video", "media_url": "https://cdn.example.com/gold50_video.mp4", "is_featured": false }
    ],

    "P_TRANSACTION_FEE": {
      "fee_type":        "platform_fee",
      "fee_value":        0.5,
      "fee_currency":    "percent",
      "fee_description": "Marketplace processing fee"
    }
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Product-App", "PRD.U.PRODUCT", @reqObj, @pjRespObj);
SELECT @pjRespObj AS 'TEST 1 - INSERT Gold Bar 50g';


-- ==================================================================================================
-- TEST 2: INSERT - Silver Bar 1kg
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
    "P_ACTION_CODE":            "PRD.U.PRODUCT",
    "P_APP_NAME":               "Gft-Product-App",

    "P_PRODUCT_REC_ID":         1,
    "P_ASSET_CODE":             "SLV",
    "P_PRODUCT_CODE":           "P-SILVER-1KG",
    "P_PRODUCT_TYPE":           "commodity",
    "P_PRODUCT_NAME":           "Fine Silver Bar 1kg",

    "P_PRODUCT_SHORT_NAME":     "Silver Bar 1kg",
    "P_PRODUCT_DESCRIPTION":    "999 purity silver bullion bar.",
    "P_PRODUCT_CLASSIFICATION": "precious_metals",
    "P_ASSET_TYPE":             "physical",
    "P_PRODUCT_QUALITY":        "999",

    "P_APPROXIMATE_WEIGHT":     1000,
    "P_WEIGHT_UNIT":            "grams",
    "P_DIMENSIONS":             "15cm x 6cm x 1cm",

    "P_IS_PHYSICAL":            true,
    "P_IS_SLICEABLE":           false,

    "P_STANDARD_PRICE":         250000,
    "P_STANDARD_PREMIUM":       5000,
    "P_PRICE_CURRENCY":         "PKR",

    "P_APPLICABLE_TAXES": [
      {
        "tax_name":          "Sales Tax",
        "taxes_description": "Government sales tax",
        "amount":             10,
        "fixed_or_percent":  "percent"
      }
    ],

    "P_QUANTITY_ON_HAND":       90,
    "P_MINIMUM_ORDER_QUANTITY": 1,
    "P_TOTAL_SOLD":             5,

    "P_OFFER_TO_CUSTOMER":      true,
    "P_DISPLAY_ORDER":          2,
    "P_ALERT_ON_LOW_STOCK":     10,

    "P_MEDIA_LIBRARY": [
      { "media_type": "image", "media_url": "https://cdn.example.com/silver1kg_front.jpg", "is_featured": true  },
      { "media_type": "image", "media_url": "https://cdn.example.com/silver1kg_back.jpg",  "is_featured": false },
      { "media_type": "image", "media_url": "https://cdn.example.com/silver1kg_side.jpg",  "is_featured": false }
    ],

    "P_TRANSACTION_FEE": {
      "fee_type":        "platform_fee",
      "fee_value":        300,
      "fee_currency":    "PKR",
      "fee_description": "Flat trading commission"
    }
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Product-App", "PRD.U.PRODUCT", @reqObj, @pjRespObj);
SELECT @pjRespObj AS 'TEST 2 - INSERT Silver Bar 1kg';


-- ==================================================================================================
-- TEST 3: INSERT - Platinum Bar 20g
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
    "P_ACTION_CODE":            "PRD.U.PRODUCT",
    "P_APP_NAME":               "Gft-Product-App",

    "P_PRODUCT_REC_ID":         2,
    "P_ASSET_CODE":             "PLT",
    "P_PRODUCT_CODE":           "P-PLAT-20G",
    "P_PRODUCT_TYPE":           "commodity",
    "P_PRODUCT_NAME":           "Platinum Bar 20g",

    "P_PRODUCT_SHORT_NAME":     "Platinum 20g",
    "P_PRODUCT_DESCRIPTION":    "Investment grade platinum bar.",
    "P_PRODUCT_CLASSIFICATION": "precious_metals",
    "P_ASSET_TYPE":             "physical",
    "P_PRODUCT_QUALITY":        "999.5",

    "P_APPROXIMATE_WEIGHT":     20,
    "P_WEIGHT_UNIT":            "grams",
    "P_DIMENSIONS":             "5cm x 3cm x 0.3cm",

    "P_IS_PHYSICAL":            true,
    "P_IS_SLICEABLE":           false,

    "P_STANDARD_PRICE":         190000,
    "P_STANDARD_PREMIUM":       4000,
    "P_PRICE_CURRENCY":         "PKR",

    "P_APPLICABLE_TAXES": [
      {
        "tax_name":          "Luxury Tax",
        "taxes_description": "Premium metals tax",
        "amount":             5,
        "fixed_or_percent":  "percent"
      }
    ],

    "P_QUANTITY_ON_HAND":       40,
    "P_MINIMUM_ORDER_QUANTITY": 1,
    "P_TOTAL_SOLD":             2,

    "P_OFFER_TO_CUSTOMER":      false,
    "P_DISPLAY_ORDER":          3,
    "P_ALERT_ON_LOW_STOCK":     5,

    "P_MEDIA_LIBRARY": [
      { "media_type": "image", "media_url": "https://cdn.example.com/platinum20_front.jpg", "is_featured": true  },
      { "media_type": "image", "media_url": "https://cdn.example.com/platinum20_back.jpg",  "is_featured": false },
      { "media_type": "video", "media_url": "https://cdn.example.com/platinum20_video.mp4", "is_featured": false }
    ],

    "P_TRANSACTION_FEE": {
      "fee_type":        "platform_fee",
      "fee_value":        0.75,
      "fee_currency":    "percent",
      "fee_description": "Premium asset transaction fee"
    }
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Product-App", "PRD.U.PRODUCT", @reqObj, @pjRespObj);
SELECT @pjRespObj AS 'TEST 3 - INSERT Platinum Bar 20g';


-- ==================================================================================================
-- TEST 4: UPDATE - Platinum Bar 20g (change product_type to PLATINUM)
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
    "P_ACTION_CODE":            "PRD.U.PRODUCT",
    "P_APP_NAME":               "Gft-Product-App",

    "P_TRADABLE_ASSETS_REC_ID": 3,
    "P_ASSET_CODE":             "PLAT-001",
    "P_PRODUCT_CODE":           "P-PLAT-20G",
    "P_PRODUCT_TYPE":           "PLATINUM",
    "P_PRODUCT_NAME":           "Platinum Bar 20g"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Product-App", "PRD.U.PRODUCT", @reqObj, @pjRespObj);
SELECT @pjRespObj AS 'TEST 4 - UPDATE Platinum product_type to PLATINUM';


-- ==================================================================================================
-- TEST 5: ERROR - Duplicate product_code on INSERT
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
    "P_ACTION_CODE":            "PRD.U.PRODUCT",
    "P_APP_NAME":               "Gft-Product-App",

    "P_TRADABLE_ASSETS_REC_ID": 1,
    "P_ASSET_CODE":             "GOLD-001",
    "P_PRODUCT_CODE":           "P-GOLD-50G",
    "P_PRODUCT_TYPE":           "commodity",
    "P_PRODUCT_NAME":           "24K Gold Bar 50g"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Product-App", "PRD.U.PRODUCT", @reqObj, @pjRespObj);
SELECT @pjRespObj AS 'TEST 5 - ERROR Duplicate product_code (expect responseCode 1)';


-- ==================================================================================================
-- TEST 6: ERROR - INSERT missing required fields (no asset_code, product_code, product_name)
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
    "P_ACTION_CODE":            "PRD.U.PRODUCT",
    "P_APP_NAME":               "Gft-Product-App",

    "P_TRADABLE_ASSETS_REC_ID": 99
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Product-App", "PRD.U.PRODUCT", @reqObj, @pjRespObj);
SELECT @pjRespObj AS 'TEST 6 - ERROR Missing required fields (expect multiple errors in message)';


-- ==================================================================================================
-- TEST 7: ERROR - UPDATE with non-existent product_rec_id
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
    "P_ACTION_CODE":            "PRD.U.PRODUCT",
    "P_APP_NAME":               "Gft-Product-App",

    "P_TRADABLE_ASSETS_REC_ID": 9999,
    "P_PRODUCT_CODE":           "P-FAKE-001",
    "P_PRODUCT_NAME":           "Ghost Product"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Product-App", "PRD.U.PRODUCT", @reqObj, @pjRespObj);
SELECT @pjRespObj AS 'TEST 7 - ERROR UPDATE non-existent product_rec_id (expect responseCode 1)';


-- ==================================================================================================
-- TEST 8: ERROR - UPDATE with duplicate product_code belonging to another row
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
    "P_ACTION_CODE":            "PRD.U.PRODUCT",
    "P_APP_NAME":               "Gft-Product-App",

    "P_TRADABLE_ASSETS_REC_ID": 3,
    "P_PRODUCT_CODE":           "P-GOLD-50G",
    "P_PRODUCT_NAME":           "Platinum Bar 20g"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Product-App", "PRD.U.PRODUCT", @reqObj, @pjRespObj);
SELECT @pjRespObj AS 'TEST 8 - ERROR UPDATE duplicate product_code from another row (expect responseCode 1)';
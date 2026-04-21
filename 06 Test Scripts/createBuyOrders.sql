-- Test 1: Missing required fields (account_number, metal, payment_method)

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "ORD.I.BUY_ORDER",
    "P_APP_NAME":       "customer-app"
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.BUY_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, validation failed: account_number, metal, payment_method required

-- Test 2: Invalid / non-existent account number

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "ORD.I.BUY_ORDER",
    "P_APP_NAME":       "customer-app",
    "P_ACCOUNT_NUMBER": "acc-433453",
    "P_METAL":          "Gold",
    "P_PRODUCT_TYPE":   "SLICE",
    "P_ORDER_SUB_TYPE": "Market",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD": "Wallet"
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.BUY_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, Customer not found

-- Test 3: SLICE Market — missing item_code

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "ORD.I.BUY_ORDER",
    "P_APP_NAME":       "customer-app",
    "P_ACCOUNT_NUMBER": "P-593",
    "P_METAL":          "Gold",
    "P_PRODUCT_TYPE":   "SLICE",
    "P_ORDER_SUB_TYPE": "Market",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD": "Wallet"
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.BUY_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, item_code is required for SLICE order


-- Test 4: SLICE Market — invalid item_code (not in inventory)

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "ORD.I.BUY_ORDER",
    "P_APP_NAME":       "customer-app",

    "P_ACCOUNT_NUMBER": "P-593",
    "P_METAL":          "Gold",
    "P_PRODUCT_TYPE":   "SLICE",
    "P_ORDER_SUB_TYPE": "Market",
    "P_ITEM_CODE":      "INVALID-ITEM",
    "P_ITEM_WEIGHT":    10,
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD": "Wallet",
      "P_AMOUNT":         150000
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.BUY_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, Inventory item not found for item code: INVALID-ITEM

-- Test 5: SLICE Market — missing item_weight and amount
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "ORD.I.BUY_ORDER",
    "P_APP_NAME":       "customer-app",

    "P_ACCOUNT_NUMBER": "P-593",
    "P_METAL":          "Silver",
    "P_PRODUCT_TYPE":   "SLICE",
    "P_ORDER_SUB_TYPE": "Market",
    "P_ITEM_CODE":      "SLV-241212",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD": "Wallet"
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.BUY_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, item_weight and amount required

-- Test 6: SLICE Market — happy path ✅
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.BUY_ORDER",
    "P_APP_NAME":           "customer-app",
    "P_ACCOUNT_NUMBER":     "P-593",
    "P_METAL":              "Gold",
    "P_PRODUCT_TYPE":       "SLICE",
    "P_ORDER_SUB_TYPE":     "Market",
    "P_ITEM_CODE":          "GLD-241212",
    "P_ITEM_WEIGHT":        10,
    "P_CUSTOMER_IP_ADDRESS":"192.168.1.1",
    "P_LATITUDE":           "24.8607",
    "P_LONGITUDE":          "67.0011",
    "P_CUSTOMER_REQUEST": {
                            "P_PAYMENT_METHOD":   "Wallet",
                            "P_AMOUNT":           150000
                            }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.BUY_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 0, Buy order created successfully

-- ==========================================================================================

-- Test 7: SLICE Limit — missing rate, weight, expiration_time

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "ORD.I.BUY_ORDER",
    "P_APP_NAME":       "customer-app",
    "P_ACCOUNT_NUMBER": "P-593",
    "P_METAL":          "Gold",
    "P_PRODUCT_TYPE":   "SLICE",
    "P_ORDER_SUB_TYPE": "Limit",
    "P_ITEM_CODE":      "GLD-241212",
    "P_ITEM_WEIGHT":    10,
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD": "Wallet"
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.BUY_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, rate, amount, weight, expiration_time required

-- Test 8: SLICE Limit — invalid order_cat
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "ORD.I.BUY_ORDER",
    "P_APP_NAME":       "customer-app",
    "P_ACCOUNT_NUMBER": "P-593",
    "P_METAL":          "Gold",
    "P_PRODUCT_TYPE":   "SLICE",
    "P_ORDER_SUB_TYPE": "Limit",
    "P_ORDER_CAT":      "INVALID",
    "P_ITEM_CODE":      "GLD-241212",
    "P_ITEM_WEIGHT":    10,
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD":   "Wallet",
      "P_RATE":             8500,
      "P_WEIGHT":           10,
      "P_AMOUNT":           85000,
      "P_EXPIRATION_TIME":  "2026-12-31T23:59:59Z"
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.BUY_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, order_cat must be GTC or IOC

-- Test 9: SLICE Limit — happy path GTC ✅
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.BUY_ORDER",
    "P_APP_NAME":           "customer-app",
    "P_ACCOUNT_NUMBER":     "P-593",
    "P_METAL":              "Gold",
    "P_PRODUCT_TYPE":       "SLICE",
    "P_ORDER_SUB_TYPE":     "Limit",
    "P_ORDER_CAT":          "GTC",
    "P_ITEM_CODE":          "GLD-241212",
    "P_ITEM_WEIGHT":        10,
    "P_CUSTOMER_IP_ADDRESS":"192.168.1.1",
    "P_LATITUDE":           "24.8607",
    "P_LONGITUDE":          "67.0011",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD":           "Wallet",
      "P_RATE":                     8500,
      "P_WEIGHT":                   10,
      "P_AMOUNT":                   85000,
      "P_EXPIRATION_TIME":          "2026-12-31T23:59:59Z",
      "P_IS_PARTIAL_FILL_ALLOWED":  true
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.BUY_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 0, Buy order created successfully

-- Test 10: SLICE Limit — happy path IOC ✅
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.BUY_ORDER",
    "P_APP_NAME":           "customer-app",
    "P_ACCOUNT_NUMBER":     "P-593",
    "P_METAL":              "Gold",
    "P_PRODUCT_TYPE":       "SLICE",
    "P_ORDER_SUB_TYPE":     "Limit",
    "P_ORDER_CAT":          "IOC",
    "P_ITEM_CODE":          "GLD-241212",
    "P_ITEM_WEIGHT":        10,
    "P_CUSTOMER_IP_ADDRESS":"192.168.1.1",
    "P_LATITUDE":           "24.8607",
    "P_LONGITUDE":          "67.0011",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD":           "Wallet",
      "P_RATE":                     8500,
      "P_WEIGHT":                   10,
      "P_AMOUNT":                   85000,
      "P_EXPIRATION_TIME":          "2026-12-31T23:59:59Z",
      "P_IS_PARTIAL_FILL_ALLOWED":  false
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.BUY_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 0, Buy order created successfully

-- Test 11: SLICE — unknown order_sub_type

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "ORD.I.BUY_ORDER",
    "P_APP_NAME":       "customer-app",
    "P_ACCOUNT_NUMBER": "P-593",
    "P_METAL":          "Gold",
    "P_PRODUCT_TYPE":   "SLICE",
    "P_ORDER_SUB_TYPE": "Unknown",
    "P_ITEM_CODE":      "GLD-241212",
    "P_ITEM_WEIGHT":    10,
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD": "Wallet",
      "P_AMOUNT":         150000
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.BUY_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, Unknown order_sub_type for SLICE. Must be Market or Limit


-- ===================================================================================
-- Test 12: PRODUCT — missing buy_items array
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "ORD.I.BUY_ORDER",
    "P_APP_NAME":       "customer-app",
    "P_ACCOUNT_NUMBER": "P-593",
    "P_METAL":          "Gold",
    "P_PRODUCT_TYPE":   "PRODUCT",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD": "Wallet",
      "P_AMOUNT":         500000
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.BUY_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, buy_items array is required and must not be empty


-- Test 13: PRODUCT — buy_items item missing required fields
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "ORD.I.BUY_ORDER",
    "P_APP_NAME":       "customer-app",
    "P_ACCOUNT_NUMBER": "P-593",
    "P_METAL":          "Gold",
    "P_PRODUCT_TYPE":   "PRODUCT",
    "P_BUY_ITEMS": [
      {
        "P_ITEM_CODE": "GLD-COIN-1G"
      }
    ],
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD": "Wallet",
      "P_AMOUNT":         500000
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.BUY_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, buy_items[0].item_weight and item_quantity required

-- Test 14: PRODUCT — invalid item_code in buy_items
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "ORD.I.BUY_ORDER",
    "P_APP_NAME":       "customer-app",
    "P_ACCOUNT_NUMBER": "P-593",
    "P_METAL":          "Gold",
    "P_PRODUCT_TYPE":   "PRODUCT",
    "P_BUY_ITEMS": [
      {
        "P_ITEM_CODE":     "INVALID-ITEM",
        "P_ITEM_WEIGHT":   10,
        "P_ITEM_QUANTITY": 1
      }
    ],
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD": "Wallet",
      "P_AMOUNT":         500000
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.BUY_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, Inventory item not found for item_code: INVALID-ITEM

-- Test 15: PRODUCT — single item happy path ✅

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.BUY_ORDER",
    "P_APP_NAME":           "customer-app",
    "P_ACCOUNT_NUMBER":     "P-593",
    "P_METAL":              "Gold",
    "P_PRODUCT_TYPE":       "PRODUCT",
    "P_CUSTOMER_IP_ADDRESS":"192.168.1.1",
    "P_LATITUDE":           "24.8607",
    "P_LONGITUDE":          "67.0011",
    "P_BUY_ITEMS": [
      {
        "P_ITEM_CODE":      "GLD-COIN-1G",
        "P_ITEM_WEIGHT":    10,
        "P_ITEM_QUANTITY":  2
      }
    ],
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD":   "Wallet",
      "P_AMOUNT":           500000
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.BUY_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 0, Buy order created successfully

-- Test 16: PRODUCT — multi-item multi-metal happy path ✅

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.BUY_ORDER",
    "P_APP_NAME":           "customer-app",
    "P_ACCOUNT_NUMBER":     "P-593",
    "P_METAL":              "Gold",
    "P_PRODUCT_TYPE":       "PRODUCT",
    "P_CUSTOMER_IP_ADDRESS":"192.168.1.1",
    "P_LATITUDE":           "24.8607",
    "P_LONGITUDE":          "67.0011",
    "P_BUY_ITEMS": [
      {
        "P_ITEM_CODE":      "GLD-RNG-1001",
        "P_ITEM_WEIGHT":    10,
        "P_ITEM_QUANTITY":  2
      },
      {
        "P_ITEM_CODE":      "SLV-241212",
        "P_ITEM_WEIGHT":    10,
        "P_ITEM_QUANTITY":  1
      }
    ],
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD":   "Wallet",
      "P_AMOUNT":           750000
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.BUY_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 0, each item has its own asset_code and spot_rate

-- Test 17: PRODUCT — insufficient cash balance
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "ORD.I.BUY_ORDER",
    "P_APP_NAME":       "customer-app",
    "P_ACCOUNT_NUMBER": "P-593",
    "P_METAL":          "Gold",
    "P_PRODUCT_TYPE":   "PRODUCT",
    "P_BUY_ITEMS": [
      {
        "P_ITEM_CODE":      "GLD-RNG-1001",
        "P_ITEM_WEIGHT":    99999,
        "P_ITEM_QUANTITY":  9999
      }
    ],
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD":   "Wallet",
      "P_AMOUNT":           999999999
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.BUY_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, Insufficient cash balance

-- Test 18: Unknown product_type
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "ORD.I.BUY_ORDER",
    "P_APP_NAME":       "customer-app",
    "P_ACCOUNT_NUMBER": "P-593",
    "P_METAL":          "Gold",
    "P_PRODUCT_TYPE":   "UNKNOWN",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD": "Wallet"
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.BUY_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, Unknown product_type for Buy. Must be SLICE or PRODUCT

-- Test 19: SLICE Market — with discount ✅
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.BUY_ORDER",
    "P_APP_NAME":           "customer-app",
    "P_ACCOUNT_NUMBER":     "P-593",
    "P_METAL":              "Gold",
    "P_PRODUCT_TYPE":       "SLICE",
    "P_ORDER_SUB_TYPE":     "Market",
    "P_ITEM_CODE":          "GLD-241212",
    "P_ITEM_WEIGHT":        10,
    "P_DISCOUNT_AMOUNT":    500,
    "P_CUSTOMER_IP_ADDRESS":"192.168.1.1",
    "P_LATITUDE":           "24.8607",
    "P_LONGITUDE":          "67.0011",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD":   "Wallet",
      "P_AMOUNT":           150000
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.BUY_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 0, total_discounts = 500 in order_summary


-- =============================================================================
--  TEST SUITE : createSellOrder  (via requestHandler)
--  Action     : ORD.I.SELL_ORDER
--  Format     : mirrors createBuyOrder / createExchangeOrder test style
--  Coverage   :
--    1.  Missing all required fields
--    2.  Missing order_sub_type only
--    3.  Invalid / non-existent account number
--    4.  Invalid asset_code (rate not found)
--    5.  SLICE Market — missing item_code
--    6.  SLICE Market — missing weight
--    7.  SLICE Market — invalid item_code (not in inventory)
--    8.  SLICE Market — insufficient metal balance
--    9.  SLICE Market — net sell amount negative (charges > proceeds)
--    10. SLICE Market — happy path ✅
--    11. SLICE Market — happy path with discount ✅
--    12. SLICE Limit  — missing rate
--    13. SLICE Limit  — missing expiration_time
--    14. SLICE Limit  — missing both rate and expiration_time
--    15. SLICE Limit  — happy path GTC ✅
--    16. SLICE Limit  — happy path GTC with partial fill allowed ✅
--    17. SLICE Limit  — happy path IOC ✅
--    18. SLICE Limit  — order_cat defaults to GTC when not provided ✅
--    19. Unknown order_sub_type
--    20. Metal wallet not found for asset_code
--    21. Cash wallet not found for customer
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Test 1: Missing all required fields
--         (account_number, asset_code, metal, payment_method, order_sub_type)
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE": "ORD.I.SELL_ORDER",
    "P_APP_NAME":    "GFT - Customer App"
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.SELL_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, validations failed
--           errors: account_number, asset_code, metal,
--                   customer_request.payment_method, order_sub_type required


-- -----------------------------------------------------------------------------
-- Test 2: Missing order_sub_type only
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "ORD.I.SELL_ORDER",
    "P_APP_NAME":       "GFT - Customer App",
    "P_ACCOUNT_NUMBER": "P-593",
    "P_ASSET_CODE":     "GLD",
    "P_METAL":          "Gold",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD": "Wallet"
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.SELL_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, order_sub_type is required (Market or Limit)


-- -----------------------------------------------------------------------------
-- Test 3: Invalid / non-existent account number
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "ORD.I.SELL_ORDER",
    "P_APP_NAME":       "GFT - Customer App",
    "P_ACCOUNT_NUMBER": "ACC-INVALID-999",
    "P_ASSET_CODE":     "GLD",
    "P_METAL":          "Gold",
    "P_ORDER_SUB_TYPE": "Market",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD": "Wallet"
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.SELL_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, Customer not found


-- -----------------------------------------------------------------------------
-- Test 4: Invalid asset_code — rate not found in tradable_assets
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "ORD.I.SELL_ORDER",
    "P_APP_NAME":       "GFT - Customer App",
    "P_ACCOUNT_NUMBER": "P-593",
    "P_ASSET_CODE":     "eee",
    "P_METAL":          "Gold",
    "P_ORDER_SUB_TYPE": "Market",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD": "Wallet"
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.SELL_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, Rate not found for asset_code: INVALID-ASSET


-- -----------------------------------------------------------------------------
-- Test 5: SLICE Market — missing item_code
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "ORD.I.SELL_ORDER",
    "P_APP_NAME":       "GFT - Customer App",
    "P_ACCOUNT_NUMBER": "P-593",
    "P_ASSET_CODE":     "GLD",
    "P_METAL":          "Gold",
    "P_ORDER_SUB_TYPE": "Market",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD": "Wallet",
      "P_WEIGHT":         10
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.SELL_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, item_code is required for SLICE order


-- -----------------------------------------------------------------------------
-- Test 6: SLICE Market — missing weight
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "ORD.I.SELL_ORDER",
    "P_APP_NAME":       "GFT - Customer App",
    "P_ACCOUNT_NUMBER": "P-593",
    "P_ASSET_CODE":     "GLD",
    "P_METAL":          "Gold",
    "P_ORDER_SUB_TYPE": "Market",
    "P_ITEM_CODE":      "GLD-241212",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD": "Wallet"
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.SELL_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, customer_request.weight is required for SLICE order


-- -----------------------------------------------------------------------------
-- Test 7: SLICE Market — invalid item_code (not in inventory)
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "ORD.I.SELL_ORDER",
    "P_APP_NAME":       "GFT - Customer App",
    "P_ACCOUNT_NUMBER": "P-593",
    "P_ASSET_CODE":     "GLD",
    "P_METAL":          "Gold",
    "P_ORDER_SUB_TYPE": "Market",
    "P_ITEM_CODE":      "INVALID-ITEM",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD": "Wallet",
      "P_WEIGHT":         10
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.SELL_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, Inventory item not found for item_code: INVALID-ITEM


-- -----------------------------------------------------------------------------
-- Test 8: SLICE Market — insufficient metal balance
--         (request more weight than the customer holds in the metal wallet)
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "ORD.I.SELL_ORDER",
    "P_APP_NAME":       "GFT - Customer App",
    "P_ACCOUNT_NUMBER": "P-593",
    "P_ASSET_CODE":     "GLD",
    "P_METAL":          "Gold",
    "P_ORDER_SUB_TYPE": "Market",
    "P_ITEM_CODE":      "GLD-241212",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD": "Wallet",
      "P_WEIGHT":         999999
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.SELL_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, Insufficient metal balance: <balance> available, 999999 required


-- -----------------------------------------------------------------------------
-- Test 9: SLICE Market — net sell amount is negative
--         (weight so tiny that charges exceed gross proceeds)
--         e.g. 0.001g gold → spot_rate * 0.001 < fixed fees (100 + 50 = 150)
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "ORD.I.SELL_ORDER",
    "P_APP_NAME":       "GFT - Customer App",
    "P_ACCOUNT_NUMBER": "P-593",
    "P_ASSET_CODE":     "GLD",
    "P_METAL":          "Gold",
    "P_ORDER_SUB_TYPE": "Market",
    "P_ITEM_CODE":      "GLD-241212",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD": "Wallet",
      "P_WEIGHT":         0.001
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.SELL_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, Net sell amount cannot be negative


-- -----------------------------------------------------------------------------
-- Test 10: SLICE Market — happy path ✅
--          Verify 2 transactions: TXN-A Metal Debit, TXN-B Cash Credit
--          Cash credit = gross proceeds - all charges
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.SELL_ORDER",
    "P_APP_NAME":           "GFT - Customer App",
    "P_ACCOUNT_NUMBER":     "P-593",
    "P_ASSET_CODE":         "GLD",
    "P_METAL":              "Gold",
    "P_ORDER_SUB_TYPE":     "Market",
    "P_ITEM_CODE":          "GLD-241212",
    "P_CUSTOMER_IP_ADDRESS":"192.168.1.1",
    "P_LATITUDE":           "24.8607",
    "P_LONGITUDE":          "67.0011",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD": "Wallet",
      "P_WEIGHT":         10
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.SELL_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 0, Sell order created successfully
--           order_json.transactions[0]: Debit  / Metal / GLD  (weight = 10)
--           order_json.transactions[1]: Credit / Cash  / CSH  (amount = spot_rate*10 - charges)
--           order_summary.total_sell_weight = 10
--           order_summary.total_order_amount = gross - making - premium - txn_fee - processing - taxes
--           order_cat = DO
--           limit_or_market = Market


-- -----------------------------------------------------------------------------
-- Test 11: SLICE Market — happy path with discount ✅
--          Verify total_discounts in order_summary and cash credit is increased
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.SELL_ORDER",
    "P_APP_NAME":           "GFT - Customer App",
    "P_ACCOUNT_NUMBER":     "P-593",
    "P_ASSET_CODE":         "GLD",
    "P_METAL":              "Gold",
    "P_ORDER_SUB_TYPE":     "Market",
    "P_ITEM_CODE":          "GLD-241212",
    "P_DISCOUNT_AMOUNT":    500,
    "P_CUSTOMER_IP_ADDRESS":"192.168.1.1",
    "P_LATITUDE":           "24.8607",
    "P_LONGITUDE":          "67.0011",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD": "Wallet",
      "P_WEIGHT":         10
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.SELL_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 0, Sell order created successfully
--           order_summary.total_discounts   = 500
--           order_summary.total_order_amount = (gross - charges) + 500
--           TXN-B transaction_amount         = total_order_amount (higher than without discount)


-- -----------------------------------------------------------------------------
-- Test 12: SLICE Limit — missing rate
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "ORD.I.SELL_ORDER",
    "P_APP_NAME":       "GFT - Customer App",
    "P_ACCOUNT_NUMBER": "P-593",
    "P_ASSET_CODE":     "GLD",
    "P_METAL":          "Gold",
    "P_ORDER_SUB_TYPE": "Limit",
    "P_ORDER_CAT":      "GTC",
    "P_ITEM_CODE":      "GLD-241212",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD":   "Wallet",
      "P_WEIGHT":           10,
      "P_EXPIRATION_TIME":  "2026-12-31 23:59:59"
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.SELL_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, customer_request.rate is required for Limit Sell order


-- -----------------------------------------------------------------------------
-- Test 13: SLICE Limit — missing expiration_time
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "ORD.I.SELL_ORDER",
    "P_APP_NAME":       "GFT - Customer App",
    "P_ACCOUNT_NUMBER": "P-593",
    "P_ASSET_CODE":     "GLD",
    "P_METAL":          "Gold",
    "P_ORDER_SUB_TYPE": "Limit",
    "P_ORDER_CAT":      "GTC",
    "P_ITEM_CODE":      "GLD-241212",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD": "Wallet",
      "P_WEIGHT":         10,
      "P_RATE":           8500
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.SELL_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, customer_request.expiration_time is required for Limit Sell order


-- -----------------------------------------------------------------------------
-- Test 14: SLICE Limit — missing both rate and expiration_time
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "ORD.I.SELL_ORDER",
    "P_APP_NAME":       "GFT - Customer App",
    "P_ACCOUNT_NUMBER": "P-593",
    "P_ASSET_CODE":     "GLD",
    "P_METAL":          "Gold",
    "P_ORDER_SUB_TYPE": "Limit",
    "P_ORDER_CAT":      "GTC",
    "P_ITEM_CODE":      "GLD-241212",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD": "Wallet",
      "P_WEIGHT":         10
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.SELL_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, both rate and expiration_time errors present in errors array


-- -----------------------------------------------------------------------------
-- Test 15: SLICE Limit — happy path GTC ✅
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.SELL_ORDER",
    "P_APP_NAME":           "GFT - Customer App",
    "P_ACCOUNT_NUMBER":     "P-593",
    "P_ASSET_CODE":         "GLD",
    "P_METAL":              "Gold",
    "P_ORDER_SUB_TYPE":     "Limit",
    "P_ORDER_CAT":          "GTC",
    "P_ITEM_CODE":          "GLD-241212",
    "P_CUSTOMER_IP_ADDRESS":"192.168.1.1",
    "P_LATITUDE":           "24.8607",
    "P_LONGITUDE":          "67.0011",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD":           "Wallet",
      "P_WEIGHT":                   10,
      "P_RATE":                     8500,
      "P_EXPIRATION_TIME":          "2026-12-31 23:59:59",
      "P_IS_PARTIAL_FILL_ALLOWED":  false
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.SELL_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 0, Sell order created successfully
--           order_cat = GTC, limit_or_market = Limit
--           customer_request.rate = 8500, weight = 10, amount = 85000
--           sold_price = rate * weight = 85000
--           order_summary.total_order_amount = 85000 - charges


-- -----------------------------------------------------------------------------
-- Test 16: SLICE Limit — happy path GTC with partial fill allowed ✅
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.SELL_ORDER",
    "P_APP_NAME":           "GFT - Customer App",
    "P_ACCOUNT_NUMBER":     "P-593",
    "P_ASSET_CODE":         "GLD",
    "P_METAL":              "Gold",
    "P_ORDER_SUB_TYPE":     "Limit",
    "P_ORDER_CAT":          "GTC",
    "P_ITEM_CODE":          "GLD-241212",
    "P_CUSTOMER_IP_ADDRESS":"192.168.1.1",
    "P_LATITUDE":           "24.8607",
    "P_LONGITUDE":          "67.0011",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD":           "Wallet",
      "P_WEIGHT":                   10,
      "P_RATE":                     8500,
      "P_EXPIRATION_TIME":          "2026-12-31 23:59:59",
      "P_IS_PARTIAL_FILL_ALLOWED":  true
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.SELL_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 0, Sell order created successfully
--           customer_request.is_partial_fill_allowed = true


-- -----------------------------------------------------------------------------
-- Test 17: SLICE Limit — happy path IOC ✅
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.SELL_ORDER",
    "P_APP_NAME":           "GFT - Customer App",
    "P_ACCOUNT_NUMBER":     "P-593",
    "P_ASSET_CODE":         "SLV",
    "P_METAL":              "Silver",
    "P_ORDER_SUB_TYPE":     "Limit",
    "P_ORDER_CAT":          "IOC",
    "P_ITEM_CODE":          "SLV-241212",
    "P_CUSTOMER_IP_ADDRESS":"192.168.1.1",
    "P_LATITUDE":           "24.8607",
    "P_LONGITUDE":          "67.0011",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD":           "Wallet",
      "P_WEIGHT":                   50,
      "P_RATE":                     120,
      "P_EXPIRATION_TIME":          "2026-06-30 23:59:59",
      "P_IS_PARTIAL_FILL_ALLOWED":  false
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.SELL_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 0, Sell order created successfully
--           order_cat = IOC, limit_or_market = Limit
--           asset_code = SLV, metal = Silver


-- -----------------------------------------------------------------------------
-- Test 18: SLICE Limit — order_cat defaults to GTC when not provided ✅
--          P_ORDER_CAT intentionally omitted
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.SELL_ORDER",
    "P_APP_NAME":           "GFT - Customer App",
    "P_ACCOUNT_NUMBER":     "P-593",
    "P_ASSET_CODE":         "GLD",
    "P_METAL":              "Gold",
    "P_ORDER_SUB_TYPE":     "Limit",
    "P_ITEM_CODE":          "GLD-241212",
    "P_CUSTOMER_IP_ADDRESS":"192.168.1.1",
    "P_LATITUDE":           "24.8607",
    "P_LONGITUDE":          "67.0011",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD":  "Wallet",
      "P_WEIGHT":          10,
      "P_RATE":            8500,
      "P_EXPIRATION_TIME": "2026-12-31 23:59:59"
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.SELL_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 0, Sell order created successfully
--           order_cat = GTC  (defaulted by SP when not provided)


-- -----------------------------------------------------------------------------
-- Test 19: Unknown order_sub_type
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "ORD.I.SELL_ORDER",
    "P_APP_NAME":       "GFT - Customer App",
    "P_ACCOUNT_NUMBER": "P-593",
    "P_ASSET_CODE":     "GLD",
    "P_METAL":          "Gold",
    "P_ORDER_SUB_TYPE": "Unknown",
    "P_ITEM_CODE":      "GLD-241212",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD": "Wallet",
      "P_WEIGHT":         10
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.SELL_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, Unknown order_sub_type for Sell. Must be Market or Limit


-- -----------------------------------------------------------------------------
-- Test 20: Metal wallet not found for the given asset_code
--          (valid account but asset_code has no METAL wallet — e.g. PLT)
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "ORD.I.SELL_ORDER",
    "P_APP_NAME":       "GFT - Customer App",
    "P_ACCOUNT_NUMBER": "P-593",
    "P_ASSET_CODE":     "PLT",
    "P_METAL":          "Platinum",
    "P_ORDER_SUB_TYPE": "Market",
    "P_ITEM_CODE":      "PLT-241212",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD": "Wallet",
      "P_WEIGHT":         10
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.SELL_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, Metal wallet not found for asset_code: PLT


-- -----------------------------------------------------------------------------
-- Test 21: Silver Market — happy path ✅
--          Confirm SP works correctly for a different metal (SLV)
--          and that asset_code drives the correct metal wallet lookup
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.SELL_ORDER",
    "P_APP_NAME":           "GFT - Customer App",
    "P_ACCOUNT_NUMBER":     "P-593",
    "P_ASSET_CODE":         "SLV",
    "P_METAL":              "Silver",
    "P_ORDER_SUB_TYPE":     "Market",
    "P_ITEM_CODE":          "SLV-241212",
    "P_CUSTOMER_IP_ADDRESS":"192.168.1.1",
    "P_LATITUDE":           "24.8607",
    "P_LONGITUDE":          "67.0011",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD": "Wallet",
      "P_WEIGHT":         50
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.SELL_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 0, Sell order created successfully
--           asset_code = SLV, metal = Silver
--           order_json.transactions[0]: Debit  / Metal / SLV  (weight = 50)
--           order_json.transactions[1]: Credit / Cash  / CSH  (amount = spot_rate*50 - charges)

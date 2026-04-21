-- =============================================================================
--  TEST SUITE : createExchangeOrder  (via requestHandler)
--  Action     : ORD.I.EXCHANGE_ORDER
--  Format     : mirrors createBuyOrder test style
--  Coverage   :
--    1.  Missing all required fields
--    2.  Same from / to asset code
--    3.  Invalid account number
--    4.  Invalid from_asset_code  (rate not found)
--    5.  Invalid to_asset_code    (rate not found)
--    6.  Invalid from_item_code   (not in inventory)
--    7.  Invalid to_item_code     (not in inventory)
--    8.  Missing from_weight
--    9.  Missing to_weight
--    10. from_metal wallet not found
--    11. to_metal wallet not found
--    12. Insufficient from_metal balance
--    13. Insufficient cash balance (after netting sell credit)
--    14. Happy path — Gold → Silver  ✅
--    15. Happy path — Silver → Gold  ✅
--    16. Happy path — with discount  ✅
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Test 1: Missing all required fields
--         (account_number, from/to asset codes, metals, item codes, weights)
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE": "ORD.I.EXCHANGE_ORDER",
    "P_APP_NAME":    "customer-app"
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.EXCHANGE_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, validations failed
--           errors: account_number, from_asset_code, to_asset_code,
--                   from_metal, to_metal, from_item_code, to_item_code,
--                   customer_request.from_weight, customer_request.to_weight required


-- -----------------------------------------------------------------------------
-- Test 2: from_asset_code and to_asset_code are the same
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":      "ORD.I.EXCHANGE_ORDER",
    "P_APP_NAME":         "customer-app",
    "P_ACCOUNT_NUMBER":   "P-593",
    "P_FROM_ASSET_CODE":  "GLD",
    "P_TO_ASSET_CODE":    "GLD",
    "P_FROM_METAL":       "Gold",
    "P_TO_METAL":         "Gold",
    "P_FROM_ITEM_CODE":   "GLD-241212",
    "P_TO_ITEM_CODE":     "GLD-241212",
    "P_CUSTOMER_REQUEST": {
      "P_FROM_WEIGHT": 10,
      "P_TO_WEIGHT":   10
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.EXCHANGE_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, from_asset_code and to_asset_code must be different


-- -----------------------------------------------------------------------------
-- Test 3: Invalid / non-existent account number
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":      "ORD.I.EXCHANGE_ORDER",
    "P_APP_NAME":         "customer-app",
    "P_ACCOUNT_NUMBER":   "ACC-INVALID-999",
    "P_FROM_ASSET_CODE":  "GLD",
    "P_TO_ASSET_CODE":    "SLV",
    "P_FROM_METAL":       "Gold",
    "P_TO_METAL":         "Silver",
    "P_FROM_ITEM_CODE":   "GLD-241212",
    "P_TO_ITEM_CODE":     "SLV-241212",
    "P_CUSTOMER_REQUEST": {
      "P_FROM_WEIGHT": 10,
      "P_TO_WEIGHT":   50
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.EXCHANGE_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, Customer not found


-- -----------------------------------------------------------------------------
-- Test 4: Invalid from_asset_code — rate not found
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":      "ORD.I.EXCHANGE_ORDER",
    "P_APP_NAME":         "customer-app",
    "P_ACCOUNT_NUMBER":   "P-593",
    "P_FROM_ASSET_CODE":  "gid",
    "P_TO_ASSET_CODE":    "SLV",
    "P_FROM_METAL":       "Gold",
    "P_TO_METAL":         "Silver",
    "P_FROM_ITEM_CODE":   "GLD-241212",
    "P_TO_ITEM_CODE":     "SLV-241212",
    "P_CUSTOMER_REQUEST": {
      "P_FROM_WEIGHT": 10,
      "P_TO_WEIGHT":   50
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.EXCHANGE_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, Rate not found for from_asset_code: INVALID-ASSET


-- -----------------------------------------------------------------------------
-- Test 5: Invalid to_asset_code — rate not found
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":      "ORD.I.EXCHANGE_ORDER",
    "P_APP_NAME":         "customer-app",
    "P_ACCOUNT_NUMBER":   "P-593",
    "P_FROM_ASSET_CODE":  "GLD",
    "P_TO_ASSET_CODE":    "scf",
    "P_FROM_METAL":       "Gold",
    "P_TO_METAL":         "Silver",
    "P_FROM_ITEM_CODE":   "GLD-241212",
    "P_TO_ITEM_CODE":     "SLV-241212",
    "P_CUSTOMER_REQUEST": {
      "P_FROM_WEIGHT": 10,
      "P_TO_WEIGHT":   50
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.EXCHANGE_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, Rate not found for to_asset_code: INVALID-ASSET


-- -----------------------------------------------------------------------------
-- Test 6: Invalid from_item_code — not in inventory
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":      "ORD.I.EXCHANGE_ORDER",
    "P_APP_NAME":         "customer-app",
    "P_ACCOUNT_NUMBER":   "P-593",
    "P_FROM_ASSET_CODE":  "GLD",
    "P_TO_ASSET_CODE":    "SLV",
    "P_FROM_METAL":       "Gold",
    "P_TO_METAL":         "Silver",
    "P_FROM_ITEM_CODE":   "INVALID-FROM-ITEM",
    "P_TO_ITEM_CODE":     "SLV-241212",
    "P_CUSTOMER_REQUEST": {
      "P_FROM_WEIGHT": 10,
      "P_TO_WEIGHT":   50
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.EXCHANGE_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, Inventory item not found for from_item_code: INVALID-FROM-ITEM


-- -----------------------------------------------------------------------------
-- Test 7: Invalid to_item_code — not in inventory
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":      "ORD.I.EXCHANGE_ORDER",
    "P_APP_NAME":         "customer-app",
    "P_ACCOUNT_NUMBER":   "P-593",
    "P_FROM_ASSET_CODE":  "GLD",
    "P_TO_ASSET_CODE":    "SLV",
    "P_FROM_METAL":       "Gold",
    "P_TO_METAL":         "Silver",
    "P_FROM_ITEM_CODE":   "GLD-241212",
    "P_TO_ITEM_CODE":     "INVALID-TO-ITEM",
    "P_CUSTOMER_REQUEST": {
      "P_FROM_WEIGHT": 10,
      "P_TO_WEIGHT":   50
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.EXCHANGE_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, Inventory item not found for to_item_code: INVALID-TO-ITEM


-- -----------------------------------------------------------------------------
-- Test 8: Missing from_weight only
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":      "ORD.I.EXCHANGE_ORDER",
    "P_APP_NAME":         "customer-app",
    "P_ACCOUNT_NUMBER":   "P-593",
    "P_FROM_ASSET_CODE":  "GLD",
    "P_TO_ASSET_CODE":    "SLV",
    "P_FROM_METAL":       "Gold",
    "P_TO_METAL":         "Silver",
    "P_FROM_ITEM_CODE":   "GLD-241212",
    "P_TO_ITEM_CODE":     "SLV-241212",
    "P_CUSTOMER_REQUEST": {
      "P_TO_WEIGHT": 50
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.EXCHANGE_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, customer_request.from_weight is required


-- -----------------------------------------------------------------------------
-- Test 9: Missing to_weight only
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":      "ORD.I.EXCHANGE_ORDER",
    "P_APP_NAME":         "customer-app",
    "P_ACCOUNT_NUMBER":   "P-593",
    "P_FROM_ASSET_CODE":  "GLD",
    "P_TO_ASSET_CODE":    "SLV",
    "P_FROM_METAL":       "Gold",
    "P_TO_METAL":         "Silver",
    "P_FROM_ITEM_CODE":   "GLD-241212",
    "P_TO_ITEM_CODE":     "SLV-241212",
    "P_CUSTOMER_REQUEST": {
      "P_FROM_WEIGHT": 10
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.EXCHANGE_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, customer_request.to_weight is required


-- -----------------------------------------------------------------------------
-- Test 10: from_metal wallet not found for the customer
--          (use a valid account but pass a from_asset_code the customer
--           has no METAL wallet for — e.g. platinum if not configured)
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":      "ORD.I.EXCHANGE_ORDER",
    "P_APP_NAME":         "customer-app",
    "P_ACCOUNT_NUMBER":   "P-593",
    "P_FROM_ASSET_CODE":  "PT",
    "P_TO_ASSET_CODE":    "SLV",
    "P_FROM_METAL":       "Platinum",
    "P_TO_METAL":         "Silver",
    "P_FROM_ITEM_CODE":   "PLT-241212",
    "P_TO_ITEM_CODE":     "SLV-241212",
    "P_CUSTOMER_REQUEST": {
      "P_FROM_WEIGHT": 5,
      "P_TO_WEIGHT":   50
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.EXCHANGE_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, Metal wallet not found for from_asset_code: PLT


-- -----------------------------------------------------------------------------
-- Test 11: to_metal wallet not found for the customer
--          (valid from, but to_asset_code has no wallet)
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":      "ORD.I.EXCHANGE_ORDER",
    "P_APP_NAME":         "customer-app",
    "P_ACCOUNT_NUMBER":   "P-593",
    "P_FROM_ASSET_CODE":  "GLD",
    "P_TO_ASSET_CODE":    "PLT",
    "P_FROM_METAL":       "Gold",
    "P_TO_METAL":         "Platinum",
    "P_FROM_ITEM_CODE":   "GLD-241212",
    "P_TO_ITEM_CODE":     "PLT-241212",
    "P_CUSTOMER_REQUEST": {
      "P_FROM_WEIGHT": 10,
      "P_TO_WEIGHT":   5
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.EXCHANGE_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, Metal wallet not found for to_asset_code: PLT


-- -----------------------------------------------------------------------------
-- Test 12: Insufficient from_metal balance
--          (request more weight than the customer actually holds)
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.EXCHANGE_ORDER",
    "P_APP_NAME":           "customer-app",
    "P_ACCOUNT_NUMBER":     "P-593",
    "P_FROM_ASSET_CODE":    "GLD",
    "P_TO_ASSET_CODE":      "SLV",
    "P_FROM_METAL":         "Gold",
    "P_TO_METAL":           "Silver",
    "P_FROM_ITEM_CODE":     "GLD-241212",
    "P_TO_ITEM_CODE":       "SLV-241212",
    "P_CUSTOMER_IP_ADDRESS":"192.168.1.1",
    "P_LATITUDE":           "24.8607",
    "P_LONGITUDE":          "67.0011",
    "P_CUSTOMER_REQUEST": {
      "P_FROM_WEIGHT": 999999,
      "P_TO_WEIGHT":   999999
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.EXCHANGE_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, Insufficient metal balance for exchange
--           message contains balance and required amounts


-- -----------------------------------------------------------------------------
-- Test 13: Insufficient cash balance to cover buy cost + charges
--          (from_metal balance is fine, but cash wallet cannot cover
--           v_bought_price + v_total_order_amount after sell credit)
--          Use a tiny from_weight so sell proceeds are small, but request
--          a very expensive to_weight so buy debit exceeds net cash.
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.EXCHANGE_ORDER",
    "P_APP_NAME":           "customer-app",
    "P_ACCOUNT_NUMBER":     "P-593",
    "P_FROM_ASSET_CODE":    "GLD",
    "P_TO_ASSET_CODE":      "SLV",
    "P_FROM_METAL":         "Gold",
    "P_TO_METAL":           "Silver",
    "P_FROM_ITEM_CODE":     "GLD-241212",
    "P_TO_ITEM_CODE":       "SLV-241212",
    "P_CUSTOMER_IP_ADDRESS":"192.168.1.1",
    "P_LATITUDE":           "24.8607",
    "P_LONGITUDE":          "67.0011",
    "P_CUSTOMER_REQUEST": {
      "P_FROM_WEIGHT": 0.001,
      "P_TO_WEIGHT":   999999
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.EXCHANGE_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 1, Insufficient cash balance to cover exchange
--           message contains balance, sell credit and buy debit amounts


-- -----------------------------------------------------------------------------
-- Test 14: Happy path — Gold → Silver  ✅
--          Verify all 4 transactions are present in the response:
--          TXN-A (GLD Metal Debit), TXN-B (Cash Credit / sell proceeds),
--          TXN-C (SLV Metal Credit), TXN-D (Cash Debit / buy cost + charges)
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.EXCHANGE_ORDER",
    "P_APP_NAME":           "customer-app",
    "P_ACCOUNT_NUMBER":     "P-593",
    "P_FROM_ASSET_CODE":    "GLD",
    "P_TO_ASSET_CODE":      "SLV",
    "P_FROM_METAL":         "Gold",
    "P_TO_METAL":           "Silver",
    "P_FROM_ITEM_CODE":     "GLD-241212",
    "P_TO_ITEM_CODE":       "SLV-241212",
    "P_CUSTOMER_IP_ADDRESS":"192.168.1.1",
    "P_LATITUDE":           "24.8607",
    "P_LONGITUDE":          "67.0011",
    "P_CUSTOMER_REQUEST": {
      "P_FROM_WEIGHT": 5,
      "P_TO_WEIGHT":   50
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.EXCHANGE_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 0, Exchange order created successfully
--           order_json.transactions has 4 entries:
--             [0] Debit  / Metal / GLD   (sell leg - metal out)
--             [1] Credit / Cash  / CSH   (sell leg - proceeds in   = from_spot_rate × 5)
--             [2] Credit / Metal / SLV   (buy  leg - metal in)
--             [3] Debit  / Cash  / CSH   (buy  leg - cost + charges = to_spot_rate × 50 + charges)
--           order_summary.total_sell_weight = 5
--           order_summary.total_buy_weight  = 50
--           metal = "Gold to Silver"


-- -----------------------------------------------------------------------------
-- Test 15: Happy path — Silver → Gold  ✅
--          Reverse direction to confirm asset-code routing is symmetric
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.EXCHANGE_ORDER",
    "P_APP_NAME":           "customer-app",
    "P_ACCOUNT_NUMBER":     "P-593",
    "P_FROM_ASSET_CODE":    "SLV",
    "P_TO_ASSET_CODE":      "GLD",
    "P_FROM_METAL":         "Silver",
    "P_TO_METAL":           "Gold",
    "P_FROM_ITEM_CODE":     "SLV-241212",
    "P_TO_ITEM_CODE":       "GLD-241212",
    "P_CUSTOMER_IP_ADDRESS":"192.168.1.1",
    "P_LATITUDE":           "24.8607",
    "P_LONGITUDE":          "67.0011",
    "P_CUSTOMER_REQUEST": {
      "P_FROM_WEIGHT": 50,
      "P_TO_WEIGHT":   5
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.EXCHANGE_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 0, Exchange order created successfully
--           order_json.transactions has 4 entries:
--             [0] Debit  / Metal / SLV   (sell leg - metal out)
--             [1] Credit / Cash  / CSH   (sell leg - proceeds in   = from_spot_rate × 50)
--             [2] Credit / Metal / GLD   (buy  leg - metal in)
--             [3] Debit  / Cash  / CSH   (buy  leg - cost + charges = to_spot_rate × 5 + charges)
--           metal = "Silver to Gold"


-- -----------------------------------------------------------------------------
-- Test 16: Happy path — with discount  ✅
--          Confirm total_discounts is reflected in order_summary and that
--          v_total_order_amount is reduced by the discount amount
-- -----------------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.EXCHANGE_ORDER",
    "P_APP_NAME":           "customer-app",
    "P_ACCOUNT_NUMBER":     "P-593",
    "P_FROM_ASSET_CODE":    "GLD",
    "P_TO_ASSET_CODE":      "SLV",
    "P_FROM_METAL":         "Gold",
    "P_TO_METAL":           "Silver",
    "P_FROM_ITEM_CODE":     "GLD-241212",
    "P_TO_ITEM_CODE":       "SLV-241212",
    "P_DISCOUNT_AMOUNT":    200,
    "P_CUSTOMER_IP_ADDRESS":"192.168.1.1",
    "P_LATITUDE":           "24.8607",
    "P_LONGITUDE":          "67.0011",
    "P_CUSTOMER_REQUEST": {
      "P_FROM_WEIGHT": 5,
      "P_TO_WEIGHT":   50
    }
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.EXCHANGE_ORDER", @reqObj, @pjObj);
SELECT @pjObj;
-- Expected: respCode 0, Exchange order created successfully
--           order_summary.total_discounts    = 200
--           order_summary.total_order_amount = (making + premium + txn_fee + processing + taxes) - 200
--           TXN-D transaction_amount         = v_bought_price + (charges - 200)
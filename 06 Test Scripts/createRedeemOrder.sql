/* =====================================================================
   TEST SCRIPT : createRedeemOrder via requestHandler
   =====================================================================
   Each test:
     1. Sets @reqObj  (the JSON input with jHeader and jData)
     2. CALLs requestHandler
     3. SELECTs @pjObj  (the JSON output) with a label
     4. Optionally verifies side-effects (orders table, wallet_ledger)

   Tests are grouped by:
     A.  Validation failures          (respCode 1)
     B.  Lookup failures              (respCode 1 with specific messages)
     C.  Happy path                   (respCode 0)
     D.  Side-effect verification     (orders, wallet_ledger rows)

   Prerequisites — the following must exist in your DB before running:
     • customers row          account_number = 'P-501'
                              customer_rec_id = 101
                              customer_json contains customer_wallets with METAL wallet for 'GLD' and CASH wallet
                              with sufficient balances (metal >= weight, cash >= charges)
     • tradable_assets row    asset_code = 'GLD'
                              tradable_assets_json.spot_rate.current_rate = 4433.85
     • inventory rows         item_code = 'GLD-BAR-1G' (item_weight=1.0, item_name='Gold Bar 1g')
                              item_code = 'GLD-COIN-5G' (item_weight=5.0, item_name='Gold Coin 5g')
     • sequences set up       ORDERS.ORDER_NUM, ORDERS.RECEIPT_NUM, ORDERS.TXN_NUM
   ===================================================================== */


/* =====================================================================
   SECTION A : Validation Failures  (respCode 1)
   ===================================================================== */

-- --------------------------------------------------------------------
-- TEST A-1 : Missing account_number
-- Expected  : respCode=1, validation failed: account_number required
-- --------------------------------------------------------------------
SELECT '=== TEST A-1 : Missing account_number ===' AS test_case;

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.REDEEM_ORDER",
    "P_APP_NAME":           "customer-app",
    "P_ASSET_CODE":         "GLD",
    "P_METAL":              "Gold",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD":   "Bank Transfer",
      "P_WEIGHT":           10.0
    },
    "P_REDEEM_ITEMS": [
      {
        "P_ITEM_CODE":      "GLD-BAR-1G",
        "P_ITEM_WEIGHT":    1.0,
        "P_ITEM_QUANTITY":  10
      }
    ]
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.REDEEM_ORDER", @reqObj, @pjObj);
SELECT @pjObj;

-- --------------------------------------------------------------------
-- TEST A-2 : Missing asset_code
-- Expected  : respCode=1, validation failed: asset_code required
-- --------------------------------------------------------------------
SELECT '=== TEST A-2 : Missing asset_code ===' AS test_case;

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.REDEEM_ORDER",
    "P_APP_NAME":           "customer-app",
    "P_ACCOUNT_NUMBER":     "P-501",
    "P_METAL":              "Gold",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD":   "Bank Transfer",
      "P_WEIGHT":           10.0
    },
    "P_REDEEM_ITEMS": [
      {
        "P_ITEM_CODE":      "GLD-BAR-1G",
        "P_ITEM_WEIGHT":    1.0,
        "P_ITEM_QUANTITY":  10
      }
    ]
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.REDEEM_ORDER", @reqObj, @pjObj);
SELECT @pjObj;

-- --------------------------------------------------------------------
-- TEST A-3 : Missing metal
-- Expected  : respCode=1, validation failed: metal required
-- --------------------------------------------------------------------
SELECT '=== TEST A-3 : Missing metal ===' AS test_case;

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.REDEEM_ORDER",
    "P_APP_NAME":           "customer-app",
    "P_ACCOUNT_NUMBER":     "P-501",
    "P_ASSET_CODE":         "GLD",
    "P_CUSTOMER_REQUEST": {
      "P_WEIGHT":           10.0
    },
    "P_REDEEM_ITEMS": [
      {
        "P_ITEM_CODE":      "GLD-BAR-1G",
        "P_ITEM_WEIGHT":    1.0,
        "P_ITEM_QUANTITY":  10
      }
    ]
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.REDEEM_ORDER", @reqObj, @pjObj);
SELECT @pjObj;

-- --------------------------------------------------------------------
-- TEST A-4 : Missing payment_method
-- Expected  : respCode=1, validation failed: payment_method required
-- --------------------------------------------------------------------
SELECT '=== TEST A-4 : Missing payment_method ===' AS test_case;

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.REDEEM_ORDER",
    "P_APP_NAME":           "customer-app",
    "P_ACCOUNT_NUMBER":     "P-501",
    "P_ASSET_CODE":         "GLD",
    "P_METAL":              "Gold",
    "P_CUSTOMER_REQUEST": {
      "P_WEIGHT":           10.0
    },
    "P_REDEEM_ITEMS": [
      {
        "P_ITEM_CODE":      "GLD-BAR-1G",
        "P_ITEM_WEIGHT":    1.0,
        "P_ITEM_QUANTITY":  10
      }
    ]
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.REDEEM_ORDER", @reqObj, @pjObj);
SELECT @pjObj;

-- --------------------------------------------------------------------
-- TEST A-5 : Missing weight
-- Expected  : respCode=1, validation failed: weight required
-- --------------------------------------------------------------------
SELECT '=== TEST A-5 : Missing weight ===' AS test_case;

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.REDEEM_ORDER",
    "P_APP_NAME":           "customer-app",
    "P_ACCOUNT_NUMBER":     "P-501",
    "P_ASSET_CODE":         "GLD",
    "P_METAL":              "Gold",
    "P_REDEEM_ITEMS": [
      {
        "P_ITEM_CODE":      "GLD-BAR-1G",
        "P_ITEM_WEIGHT":    1.0,
        "P_ITEM_QUANTITY":  10
      }
    ]
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.REDEEM_ORDER", @reqObj, @pjObj);
SELECT @pjObj;

-- --------------------------------------------------------------------
-- TEST A-6 : Zero weight
-- Expected  : respCode=1, validation failed: weight must be greater than 0
-- --------------------------------------------------------------------
SELECT '=== TEST A-6 : Zero weight ===' AS test_case;

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.REDEEM_ORDER",
    "P_APP_NAME":           "customer-app",
    "P_ACCOUNT_NUMBER":     "P-501",
    "P_ASSET_CODE":         "GLD",
    "P_METAL":              "Gold",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD":   "Bank Transfer",
      "P_WEIGHT":           0.0
    },
    "P_REDEEM_ITEMS": [
      {
        "P_ITEM_CODE":      "GLD-BAR-1G",
        "P_ITEM_WEIGHT":    1.0,
        "P_ITEM_QUANTITY":  10
      }
    ]
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.REDEEM_ORDER", @reqObj, @pjObj);
SELECT @pjObj;

-- --------------------------------------------------------------------
-- TEST A-7 : Empty redeem_items
-- Expected  : respCode=1, validation failed: redeem_items required and not empty
-- --------------------------------------------------------------------
SELECT '=== TEST A-7 : Empty redeem_items ===' AS test_case;

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.REDEEM_ORDER",
    "P_APP_NAME":           "customer-app",
    "P_ACCOUNT_NUMBER":     "P-501",
    "P_ASSET_CODE":         "GLD",
    "P_METAL":              "Gold",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD":   "Bank Transfer",
      "P_WEIGHT":           10.0
    },
    "P_REDEEM_ITEMS": []
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.REDEEM_ORDER", @reqObj, @pjObj);
SELECT @pjObj;

-- --------------------------------------------------------------------
-- TEST A-8 : Missing item_code
-- Expected  : respCode=1, validation failed: item_code required
-- --------------------------------------------------------------------
SELECT '=== TEST A-8 : Missing item_code ===' AS test_case;

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.REDEEM_ORDER",
    "P_APP_NAME":           "customer-app",
    "P_ACCOUNT_NUMBER":     "P-501",
    "P_ASSET_CODE":         "GLD",
    "P_METAL":              "Gold",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD":   "Bank Transfer",
      "P_WEIGHT":           10.0
    },
    "P_REDEEM_ITEMS": [
      {
        "P_ITEM_WEIGHT":    1.0,
        "P_ITEM_QUANTITY":  10
      }
    ]
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.REDEEM_ORDER", @reqObj, @pjObj);
SELECT @pjObj;

-- --------------------------------------------------------------------
-- TEST A-9 : Weight mismatch
-- Expected  : respCode=1, weight does not match total weight of items
-- --------------------------------------------------------------------
SELECT '=== TEST A-9 : Weight mismatch ===' AS test_case;

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.REDEEM_ORDER",
    "P_APP_NAME":           "customer-app",
    "P_ACCOUNT_NUMBER":     "P-501",
    "P_ASSET_CODE":         "GLD",
    "P_METAL":              "Gold",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD":   "Bank Transfer",
      "P_WEIGHT":           5.0
    },
    "P_REDEEM_ITEMS": [
      {
        "P_ITEM_CODE":      "GLD-241212",
        "P_ITEM_WEIGHT":    1.0,
        "P_ITEM_QUANTITY":  10
      }
    ]
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.REDEEM_ORDER", @reqObj, @pjObj);
SELECT @pjObj;

/* =====================================================================
   SECTION B : Lookup Failures
   ===================================================================== */

-- --------------------------------------------------------------------
-- TEST B-1 : Customer not found
-- Expected  : respCode=1, Customer not found
-- --------------------------------------------------------------------
SELECT '=== TEST B-1 : Customer not found ===' AS test_case;

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.REDEEM_ORDER",
    "P_APP_NAME":           "customer-app",
    "P_ACCOUNT_NUMBER":     "NONEXISTENT",
    "P_ASSET_CODE":         "GLD",
    "P_METAL":              "Gold",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD":   "Bank Transfer",
      "P_WEIGHT":           10.0
    },
    "P_REDEEM_ITEMS": [
      {
        "P_ITEM_CODE":      "GLD-241212",
        "P_ITEM_WEIGHT":    1.0,
        "P_ITEM_QUANTITY":  10
      }
    ]
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.REDEEM_ORDER", @reqObj, @pjObj);
SELECT @pjObj;

-- --------------------------------------------------------------------
-- TEST B-2 : Rate not found
-- Expected  : respCode=1, Rate not found for asset_code
-- --------------------------------------------------------------------
SELECT '=== TEST B-2 : Rate not found ===' AS test_case;

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.REDEEM_ORDER",
    "P_APP_NAME":           "customer-app",
    "P_ACCOUNT_NUMBER":     "P-501",
    "P_ASSET_CODE":         "gdfgd",
    "P_METAL":              "Gold",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD":   "Bank Transfer",
      "P_WEIGHT":           10.0
    },
    "P_REDEEM_ITEMS": [
      {
        "P_ITEM_CODE":      "GLD-241212",
        "P_ITEM_WEIGHT":    1.0,
        "P_ITEM_QUANTITY":  10
      }
    ]
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.REDEEM_ORDER", @reqObj, @pjObj);
SELECT @pjObj;

-- --------------------------------------------------------------------
-- TEST B-3 : Inventory item not found
-- Expected  : respCode=1, Inventory item not found for item_code
-- --------------------------------------------------------------------
SELECT '=== TEST B-3 : Inventory item not found ===' AS test_case;

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.REDEEM_ORDER",
    "P_APP_NAME":           "customer-app",
    "P_ACCOUNT_NUMBER":     "P-501",
    "P_ASSET_CODE":         "GLD",
    "P_METAL":              "Gold",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD":   "Bank Transfer",
      "P_WEIGHT":           10.0
    },
    "P_REDEEM_ITEMS": [
      {
        "P_ITEM_CODE":      "NONEXISTENT",
        "P_ITEM_WEIGHT":    1.0,
        "P_ITEM_QUANTITY":  10
      }
    ]
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.REDEEM_ORDER", @reqObj, @pjObj);
SELECT @pjObj;

-- --------------------------------------------------------------------
-- TEST B-4 : Metal wallet not found
-- Expected  : respCode=1, Metal wallet not found for asset_code
-- --------------------------------------------------------------------
SELECT '=== TEST B-4 : Metal wallet not found ===' AS test_case;

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.REDEEM_ORDER",
    "P_APP_NAME":           "customer-app",
    "P_ACCOUNT_NUMBER":     "P-501",
    "P_ASSET_CODE":         "SLV",
    "P_METAL":              "Silver",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD":   "Bank Transfer",
      "P_WEIGHT":           10.0
    },
    "P_REDEEM_ITEMS": [
      {
        "P_ITEM_CODE":      "GLD-241212",
        "P_ITEM_WEIGHT":    1.0,
        "P_ITEM_QUANTITY":  10
      }
    ]
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.REDEEM_ORDER", @reqObj, @pjObj);
SELECT @pjObj;

-- --------------------------------------------------------------------
-- TEST B-5 : Cash wallet not found
-- Expected  : respCode=1, Cash wallet not found for customer
-- --------------------------------------------------------------------
SELECT '=== TEST B-5 : Cash wallet not found ===' AS test_case;

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.REDEEM_ORDER",
    "P_APP_NAME":           "customer-app",
    "P_ACCOUNT_NUMBER":     "P-501",
    "P_ASSET_CODE":         "GLD",
    "P_METAL":              "Gold",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD":   "Bank Transfer",
      "P_WEIGHT":           10.0
    },
    "P_REDEEM_ITEMS": [
      {
        "P_ITEM_CODE":      "GLD-241212",
        "P_ITEM_WEIGHT":    1.0,
        "P_ITEM_QUANTITY":  10
      }
    ]
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.REDEEM_ORDER", @reqObj, @pjObj);
SELECT @pjObj;

-- --------------------------------------------------------------------
-- TEST B-6 : Insufficient metal balance
-- Expected  : respCode=1, Insufficient metal balance
-- --------------------------------------------------------------------
SELECT '=== TEST B-6 : Insufficient metal balance ===' AS test_case;

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.REDEEM_ORDER",
    "P_APP_NAME":           "customer-app",
    "P_ACCOUNT_NUMBER":     "P-501",
    "P_ASSET_CODE":         "GLD",
    "P_METAL":              "Gold",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD":   "Bank Transfer",
      "P_WEIGHT":           1000.0
    },
    "P_REDEEM_ITEMS": [
      {
        "P_ITEM_CODE":      "GLD-241212",
        "P_ITEM_WEIGHT":    1.0,
        "P_ITEM_QUANTITY":  1000
      }
    ]
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.REDEEM_ORDER", @reqObj, @pjObj);
SELECT @pjObj;

-- --------------------------------------------------------------------
-- TEST B-7 : Negative charges
-- Expected  : respCode=1, Net charges amount cannot be negative
-- --------------------------------------------------------------------
SELECT '=== TEST B-7 : Negative charges ===' AS test_case;

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.REDEEM_ORDER",
    "P_APP_NAME":           "customer-app",
    "P_ACCOUNT_NUMBER":     "P-501",
    "P_ASSET_CODE":         "GLD",
    "P_METAL":              "Gold",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD":   "Bank Transfer",
      "P_WEIGHT":           10.0
    },
    "P_REDEEM_ITEMS": [
      {
        "P_ITEM_CODE":      "GLD-241212",
        "P_ITEM_WEIGHT":    1.0,
        "P_ITEM_QUANTITY":  10
      }
    ],
    "P_DISCOUNT_AMOUNT":    10000.00
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.REDEEM_ORDER", @reqObj, @pjObj);
SELECT @pjObj;

-- --------------------------------------------------------------------
-- TEST B-8 : Insufficient cash balance
-- Expected  : respCode=1, Insufficient cash balance to cover redemption charges
-- --------------------------------------------------------------------
SELECT '=== TEST B-8 : Insufficient cash balance ===' AS test_case;

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.REDEEM_ORDER",
    "P_APP_NAME":           "customer-app",
    "P_ACCOUNT_NUMBER":     "P-501",
    "P_ASSET_CODE":         "GLD",
    "P_METAL":              "Gold",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD":   "Bank Transfer",
      "P_WEIGHT":           10.0
    },
    "P_REDEEM_ITEMS": [
      {
        "P_ITEM_CODE":      "GLD-241212",
        "P_ITEM_WEIGHT":    1.0,
        "P_ITEM_QUANTITY":  10
      }
    ]
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.REDEEM_ORDER", @reqObj, @pjObj);
SELECT @pjObj;

/* =====================================================================
   SECTION C : Happy Path  (respCode 0)
   ===================================================================== */

-- --------------------------------------------------------------------
-- TEST C-1 : Successful redeem order
-- Expected  : respCode=0, Redeem order inserted successfully
-- --------------------------------------------------------------------
SELECT '=== TEST C-1 : Successful redeem ===' AS test_case;

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.REDEEM_ORDER",
    "P_APP_NAME":           "customer-app",
    "P_ACCOUNT_NUMBER":     "P-501",
    "P_ASSET_CODE":         "GLD",
    "P_METAL":              "Gold",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD":   "Bank Transfer",
      "P_WEIGHT":           10.0
    },
    "P_REDEEM_ITEMS": [
      {
        "P_ITEM_CODE":      "GLD-241212",
        "P_ITEM_WEIGHT":    1.0,
        "P_ITEM_QUANTITY":  10
      }
    ],
    "P_CUSTOMER_IP_ADDRESS":"192.168.1.1",
    "P_LATITUDE":          40.7128,
    "P_LONGITUDE":         -74.0060,
    "P_NOTES":             "Test redeem order"
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.REDEEM_ORDER", @reqObj, @pjObj);
SELECT @pjObj;

-- --------------------------------------------------------------------
-- TEST C-2 : Successful redeem order with multiple redeem_items
-- Expected  : respCode=0, total_qty_to_buy = 2
-- --------------------------------------------------------------------
SELECT '=== TEST C-2 : Successful redeem with multiple items ===' AS test_case;

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "ORD.I.REDEEM_ORDER",
    "P_APP_NAME":           "customer-app",
    "P_ACCOUNT_NUMBER":     "P-501",
    "P_ASSET_CODE":         "GLD",
    "P_METAL":              "Gold",
    "P_CUSTOMER_REQUEST": {
      "P_PAYMENT_METHOD":   "Bank Transfer",
      "P_WEIGHT":           25.0
    },
    "P_REDEEM_ITEMS": [
      {
        "P_ITEM_CODE":      "GLD-241212",
        "P_ITEM_WEIGHT":    15.0,
        "P_ITEM_QUANTITY":  1
      },
      {
        "P_ITEM_CODE":      "GLD-RNG-1001",
        "P_ITEM_WEIGHT":    10.0,
        "P_ITEM_QUANTITY":  1
      }
    ],
    "P_CUSTOMER_IP_ADDRESS":"192.168.1.1",
    "P_LATITUDE":          40.7128,
    "P_LONGITUDE":         -74.0060,
    "P_NOTES":             "Test redeem order with 2 items"
  }
}';
CALL requestHandler("127.0.0.0", "GFT - Customer App", "ORD.I.REDEEM_ORDER", @reqObj, @pjObj);
SELECT @pjObj;

/* =====================================================================
   SECTION D : Side-effect Verification
   ===================================================================== */

-- --------------------------------------------------------------------
-- TEST D-1 : Verify order inserted
-- --------------------------------------------------------------------
SELECT '=== TEST D-1 : Verify order inserted ===' AS test_case;

SELECT order_rec_id,
       order_number,
       order_status,
       order_type,
       metal,
       order_json->>'$.customer_request.total_qty_to_buy' AS total_qty_to_buy,
       order_json->>'$.order_summary.total_redeem_weight' AS total_weight
FROM orders
WHERE order_type = 'Redeem'
ORDER BY order_rec_id DESC
LIMIT 1;

-- --------------------------------------------------------------------
-- TEST D-2 : Verify wallet transactions
-- --------------------------------------------------------------------
SELECT '=== TEST D-2 : Verify wallet transactions ===' AS test_case;

SELECT wl.wallet_ledger_rec_id, wl.transaction_type, wl.wallet_type, wl.asset_code, wl.transaction_amount, wl.balance_after, wl.description
FROM wallet_ledger wl
WHERE wl.order_number LIKE 'ORD-%'
ORDER BY wl.wallet_ledger_rec_id DESC
LIMIT 5;

-- --------------------------------------------------------------------
-- TEST D-3 : Verify customer_products updated for redeem order
-- --------------------------------------------------------------------
SELECT '=== TEST D-3 : Verify customer_products updated ===' AS test_case;

SELECT JSON_PRETTY(JSON_EXTRACT(c.customer_json, '$.customer_products')) AS customer_products
FROM customer c
WHERE c.account_num = 'P-501';
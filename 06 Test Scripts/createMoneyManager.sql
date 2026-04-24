-- =====================================================================
-- Test Suite: createMoneyTransaction
-- =====================================================================


-- =====================================================================
-- TEST 1: Valid Cash Deposit
-- =====================================================================
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "TRN.I.MONEY_TRANSACTION",
    "P_APP_NAME":           "Gft-Customer-App",
    
    "P_REQUEST_TYPE":       "deposit",
    "P_TRANSACTION_TYPE":   "cash deposit",
    "P_CUSTOMER_REC_ID":    1,
    "P_SENDER_INFO": {
      "P_AMOUNT_SENT":      500.00,
      "P_INITIATED_BY":     "Customer",
      "P_INSTITUTION_NAME": "GFT Bank"
    },
    "P_RECEIVER_INFO": {
      "P_AMOUNT_RECEIVED":  500.00
    }
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "TRN.I.MONEY_TRANSACTION", @reqObj, @pjObj);
SELECT '-- TEST 1: Valid Cash Deposit --' AS test_label, @pjObj AS response;


-- =====================================================================
-- TEST 2: Valid Bank Transfer Withdrawal
-- =====================================================================
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "TRN.I.MONEY_TRANSACTION",
    "P_APP_NAME":           "Gft-Customer-App",
    "P_REQUEST_TYPE":       "withdraw",
    "P_TRANSACTION_TYPE":   "bank transfer",
    "P_CUSTOMER_REC_ID":    1,
    "P_SENDER_INFO": {
      "P_AMOUNT_SENT":      200.00,
      "P_ACCOUNT_NUMBER":   "1234567890",
      "P_ACCOUNT_HOLDER_NAME": "Amran Khan"
    },
    "P_RECEIVER_INFO": {
      "P_AMOUNT_RECEIVED":  200.00,
      "P_INSTITUTION_NAME": "Allied Bank"
    }
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "TRN.I.MONEY_TRANSACTION", @reqObj, @pjObj);
SELECT '-- TEST 2: Valid Bank Transfer Withdrawal --' AS test_label, @pjObj AS response;


-- =====================================================================
-- TEST 3: Valid Credit Card Deposit (with full card info)
-- =====================================================================
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "TRN.I.MONEY_TRANSACTION",
    "P_APP_NAME":           "Gft-Customer-App",
    "P_REQUEST_TYPE":       "deposit",
    "P_TRANSACTION_TYPE":   "credit card",
    "P_CUSTOMER_REC_ID":    1,
    "P_SENDER_INFO": {
      "P_AMOUNT_SENT":      1000.00,
      "P_TRANSACTION_ID":   "CC-TXN-001"
    },
    "P_RECEIVER_INFO": {
      "P_AMOUNT_RECEIVED":  1000.00,
      "P_PROCESSING_FEE":   2.50
    },
    "P_CARD_INFO": {
      "P_CARD_NUMBER":      "4111111111111111",
      "P_CVV2":             "123"
    },
    "P_PROCESSOR_NAME":     "STRIPE",
    "P_PROCESSOR_TOKEN":    "tok_test_abc123"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "TRN.I.MONEY_TRANSACTION", @reqObj, @pjObj);
SELECT '-- TEST 3: Valid Credit Card Deposit --' AS test_label, @pjObj AS response;


-- =====================================================================
-- TEST 4: Valid E-Wallet Deposit
-- =====================================================================
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "TRN.I.MONEY_TRANSACTION",
    "P_APP_NAME":           "Gft-Customer-App",
    "P_REQUEST_TYPE":       "deposit",
    "P_TRANSACTION_TYPE":   "e wallets",
    "P_CUSTOMER_REC_ID":    1,
    "P_SENDER_INFO": {
      "P_AMOUNT_SENT":      350.00,
      "P_INSTITUTION_NAME": "JazzCash"
    },
    "P_RECEIVER_INFO": {
      "P_AMOUNT_RECEIVED":  350.00
    }
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "TRN.I.MONEY_TRANSACTION", @reqObj, @pjObj);
SELECT '-- TEST 4: Valid E-Wallet Deposit --' AS test_label, @pjObj AS response;


-- =====================================================================
-- TEST 5: [FAIL] Missing request_type
-- =====================================================================
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "TRN.I.MONEY_TRANSACTION",
    "P_APP_NAME":           "Gft-Customer-App",
    "P_TRANSACTION_TYPE":   "cash deposit",
    "P_CUSTOMER_REC_ID":    1,
    "P_SENDER_INFO": {
      "P_AMOUNT_SENT":      100.00
    },
    "P_RECEIVER_INFO": {
      "P_AMOUNT_RECEIVED":  100.00
    }
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "TRN.I.MONEY_TRANSACTION", @reqObj, @pjObj);
SELECT '-- TEST 5: [FAIL] Missing request_type --' AS test_label, @pjObj AS response;


-- =====================================================================
-- TEST 6: [FAIL] Invalid request_type value
-- =====================================================================
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "TRN.I.MONEY_TRANSACTION",
    "P_APP_NAME":           "Gft-Customer-App",
    "P_REQUEST_TYPE":       "transfer",
    "P_TRANSACTION_TYPE":   "cash deposit",
    "P_CUSTOMER_REC_ID":    1,
    "P_SENDER_INFO": {
      "P_AMOUNT_SENT":      100.00
    },
    "P_RECEIVER_INFO": {
      "P_AMOUNT_RECEIVED":  100.00
    }
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "TRN.I.MONEY_TRANSACTION", @reqObj, @pjObj);
SELECT '-- TEST 6: [FAIL] Invalid request_type value --' AS test_label, @pjObj AS response;


-- =====================================================================
-- TEST 7: [FAIL] Withdrawal via cash deposit (blocked transaction type)
-- =====================================================================
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "TRN.I.MONEY_TRANSACTION",
    "P_APP_NAME":           "Gft-Customer-App",
    "P_REQUEST_TYPE":       "withdraw",
    "P_TRANSACTION_TYPE":   "cash deposit",
    "P_CUSTOMER_REC_ID":    1,
    "P_SENDER_INFO": {
      "P_AMOUNT_SENT":      100.00
    },
    "P_RECEIVER_INFO": {
      "P_AMOUNT_RECEIVED":  100.00
    }
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "TRN.I.MONEY_TRANSACTION", @reqObj, @pjObj);
SELECT '-- TEST 7: [FAIL] Withdrawal via cash deposit --' AS test_label, @pjObj AS response;


-- =====================================================================
-- TEST 8: [FAIL] Withdrawal via credit card (blocked transaction type)
-- =====================================================================
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "TRN.I.MONEY_TRANSACTION",
    "P_APP_NAME":           "Gft-Customer-App",
    "P_REQUEST_TYPE":       "withdraw",
    "P_TRANSACTION_TYPE":   "credit card",
    "P_CUSTOMER_REC_ID":    1,
    "P_SENDER_INFO": {
      "P_AMOUNT_SENT":      100.00
    },
    "P_RECEIVER_INFO": {
      "P_AMOUNT_RECEIVED":  100.00
    }
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "TRN.I.MONEY_TRANSACTION", @reqObj, @pjObj);
SELECT '-- TEST 8: [FAIL] Withdrawal via credit card --' AS test_label, @pjObj AS response;


-- =====================================================================
-- TEST 9: [FAIL] Zero amount
-- =====================================================================
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "TRN.I.MONEY_TRANSACTION",
    "P_APP_NAME":           "Gft-Customer-App",
    "P_REQUEST_TYPE":       "deposit",
    "P_TRANSACTION_TYPE":   "bank transfer",
    "P_CUSTOMER_REC_ID":    1,
    "P_SENDER_INFO": {
      "P_AMOUNT_SENT":      0
    },
    "P_RECEIVER_INFO": {
      "P_AMOUNT_RECEIVED":  0
    }
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "TRN.I.MONEY_TRANSACTION", @reqObj, @pjObj);
SELECT '-- TEST 9: [FAIL] Zero amount --' AS test_label, @pjObj AS response;


-- =====================================================================
-- TEST 10: [FAIL] Missing amount fields entirely
-- =====================================================================
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "TRN.I.MONEY_TRANSACTION",
    "P_APP_NAME":           "Gft-Customer-App",
    "P_REQUEST_TYPE":       "deposit",
    "P_TRANSACTION_TYPE":   "bank transfer",
    "P_CUSTOMER_REC_ID":    1
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "TRN.I.MONEY_TRANSACTION", @reqObj, @pjObj);
SELECT '-- TEST 10: [FAIL] Missing amount fields --' AS test_label, @pjObj AS response;


-- =====================================================================
-- TEST 11: [FAIL] Credit card deposit - missing CVV2
-- =====================================================================
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "TRN.I.MONEY_TRANSACTION",
    "P_APP_NAME":           "Gft-Customer-App",
    "P_REQUEST_TYPE":       "deposit",
    "P_TRANSACTION_TYPE":   "credit card",
    "P_CUSTOMER_REC_ID":    1,
    "P_SENDER_INFO": {
      "P_AMOUNT_SENT":      500.00
    },
    "P_RECEIVER_INFO": {
      "P_AMOUNT_RECEIVED":  500.00
    },
    "P_CARD_INFO": {
      "P_CARD_NUMBER":      "4111111111111111"
    },
    "P_PROCESSOR_NAME":     "STRIPE",
    "P_PROCESSOR_TOKEN":    "tok_test_abc123"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "TRN.I.MONEY_TRANSACTION", @reqObj, @pjObj);
SELECT '-- TEST 11: [FAIL] Credit card - missing CVV2 --' AS test_label, @pjObj AS response;


-- =====================================================================
-- TEST 12: [FAIL] Credit card deposit - missing processor_name
-- =====================================================================
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "TRN.I.MONEY_TRANSACTION",
    "P_APP_NAME":           "Gft-Customer-App",
    "P_REQUEST_TYPE":       "deposit",
    "P_TRANSACTION_TYPE":   "credit card",
    "P_CUSTOMER_REC_ID":    1,
    "P_SENDER_INFO": {
      "P_AMOUNT_SENT":      500.00
    },
    "P_RECEIVER_INFO": {
      "P_AMOUNT_RECEIVED":  500.00
    },
    "P_CARD_INFO": {
      "P_CARD_NUMBER":      "4111111111111111",
      "P_CVV2":             "456"
    },
    "P_PROCESSOR_TOKEN":    "tok_test_abc123"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "TRN.I.MONEY_TRANSACTION", @reqObj, @pjObj);
SELECT '-- TEST 12: [FAIL] Credit card - missing processor_name --' AS test_label, @pjObj AS response;


-- =====================================================================
-- TEST 13: [FAIL] Missing customer_rec_id
-- =====================================================================
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "TRN.I.MONEY_TRANSACTION",
    "P_APP_NAME":           "Gft-Customer-App",
    "P_REQUEST_TYPE":       "deposit",
    "P_TRANSACTION_TYPE":   "bank transfer",
    "P_SENDER_INFO": {
      "P_AMOUNT_SENT":      100.00
    },
    "P_RECEIVER_INFO": {
      "P_AMOUNT_RECEIVED":  100.00
    }
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "TRN.I.MONEY_TRANSACTION", @reqObj, @pjObj);
SELECT '-- TEST 13: [FAIL] Missing customer_rec_id --' AS test_label, @pjObj AS response;


-- =====================================================================
-- TEST 14: [FAIL] Multiple validation errors at once
-- (missing request_type, missing amount, missing customer_rec_id)
-- =====================================================================
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":        "TRN.I.MONEY_TRANSACTION",
    "P_APP_NAME":           "Gft-Customer-App",
    "P_TRANSACTION_TYPE":   "bank transfer"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "TRN.I.MONEY_TRANSACTION", @reqObj, @pjObj);
SELECT '-- TEST 14: [FAIL] Multiple validation errors --' AS test_label, @pjObj AS response;
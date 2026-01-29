-- ===============================================
-- CURRENT ASSETS INSERTED
-- ===============================================


-- ===============================================
-- ASSET TYPE: METAL - GOLD
-- ===============================================

SET @metal_type_gold = CAST(
                        '{
                            "tradable_assets_rec_id"        : 1,
                            "asset_name"            		: "Gold",
                            "short_name"            		: "gold",
                            "asset_code"            		: "GLD",
                            "asset_intl_code"       		: "XAU",
                            "wallet_type"            		: "METAL",
                            "forex_code"            		: "XAU",
                            "available_to_customers"		: true,

                            "how_to_measure"                : "by_weight",
                            "standard_units"                : "gram",
                            "min_order"                     : 1.0,
                            "max_order"                     : 10000.0,
                            "minimum_reedem_level"          : "1 g",
                            "max_reedem_level"              : "10 toz",

                            "taxes" : {
                                "GST"                       : "18%",
                                "Luxury_Tax"                : "2%",
                                "Import_Duty"               : "5%",
                                "withholding_tax"           : "10%"
                            },

                            "stats" : {
                                "products_weight"           : 1500.0,
                                "bullion_weight_available"  : 5000.0
                            },

                            "spot_rate" : {
                                "url"                       : "https://metals-api.com/",
                                "unit"                      : "gram",
                                "quality"                   : "24K",
                                "api_name"                  : "metals-api",
                                "currency"                  : "USD",
                                "updated_at"                : "2026-01-16T06:00:00Z",
                                "current_rate"              : 4433.85
                            },

                            "media_library" : [
                                {
                                    "url"                   : "https://example.com/images/gold_front.jpg",
                                    "description"           : "Front view of Gold Bar",
                                    "uploaded_at"           : "2024-05-20T09:15:00Z"
                                },
                                {
                                    "url"                   : "https://example.com/images/gold_side.jpg",
                                    "description"           : "Side view of Gold Bar",
                                    "uploaded_at"           : "2024-05-22T11:45:00Z"
                                }
                            ]
                        }' AS JSON);

INSERT INTO tradable_assets
SET
    asset_name                      = 'GOLD',
    short_name                      = 'gold',
    asset_code                      = 'GLD',
    asset_intl_code                 = 'XAU',
    asset_type                      = 'METAL',
    forex_code                      = 'XAU',
    available_to_customers          = TRUE,
    tradable_assets_json            = fillTemplate(@metal_type_gold, getTemplate('tradable_assets')),
    row_metadata                    = castJson('row_metadata');

-- ===============================================
-- ASSET TYPE: METAL - SILVER
-- ===============================================
SET @metal_type_silver = CAST('{
                                "tradable_assets_rec_id"        : 2,
                                "asset_name"                    : "Silver",
                                "short_name"                    : "silver",
                                "asset_code"                    : "SLV",
                                "asset_intl_code"               : "XAG",
                                "wallet_type"                   : "METAL",
                                "forex_code"                    : "XAG",
                                "available_to_customers"        : true,                         

                                "how_to_measure"                : "by_weight",
                                "standard_units"                : "gram",
                                "min_order"                     : 10.0,
                                "max_order"                     : 20000.0,
                                "minimum_reedem_level"          : "10 g",
                                "max_reedem_level"              : "1000 toz",                           

                                "taxes" : {
                                    "GST"                       : "18%",
                                    "Luxury_Tax"                : "2%",
                                    "Import_Duty"               : "5%",
                                    "withholding_tax"           : "10%"
                                },                          

                                "stats" : {
                                    "products_weight"           : 3000.0,
                                    "bullion_weight_available"  : 8000.0
                                },                          

                                "spot_rate" : {
                                    "url"                       : "https://metals-api.com/",
                                    "unit"                      : "gram",
                                    "quality"                   : "999",
                                    "api_name"                  : "metals-api",
                                    "currency"                  : "USD",
                                    "updated_at"                : "2026-01-16T06:00:00Z",
                                    "current_rate"              : 55.32
                                },                          

                                "media_library" : [
                                    {
                                        "url"                   : "https://example.com/images/silver_front.jpg",
                                        "description"           : "Front view of Silver Bar",
                                        "uploaded_at"           : "2024-05-20T09:15:00Z"
                                    },
                                    {
                                        "url"                   : "https://example.com/images/silver_side.jpg",
                                        "description"           : "Side view of Silver Bar",
                                        "uploaded_at"           : "2024-05-22T11:45:00Z"
                                    }
                                ]
                            }' AS JSON);

INSERT INTO tradable_assets
SET
    asset_name                      = 'SILVER',
    short_name                      = 'silver',
    asset_code                      = 'SLV',
    asset_intl_code                 = 'XAG',
    asset_type                      = 'METAL',
    forex_code                      = 'XAG',
    available_to_customers          = TRUE,
    tradable_assets_json            = fillTemplate(@metal_type_silver, getTemplate('tradable_assets')),
    row_metadata                    = castJson('row_metadata');


-- ===============================================
-- ASSET TYPE: METAL - PLATINUM
-- ===============================================
SET @metal_type_platinum = CAST('{
                            "tradable_assets_rec_id"        : 3,
                            "asset_name"                    : "Platinum",
                            "short_name"                    : "platinum",
                            "asset_code"                    : "PT",
                            "asset_intl_code"               : "XPT",
                            "wallet_type"                   : "METAL",
                            "forex_code"                    : "XPT",
                            "available_to_customers"        : false,                        

                            "how_to_measure"                : "by_weight",
                            "standard_units"                : "gram",
                            "min_order"                     : 5.0,
                            "max_order"                     : 5000.0,
                            "minimum_reedem_level"          : "5 g",
                            "max_reedem_level"              : "50 toz",                     

                            "taxes" : {
                                "GST"                       : "18%",
                                "Luxury_Tax"                : "2%",
                                "Import_Duty"               : "5%",
                                "withholding_tax"           : "10%"
                            },                      

                            "stats" : {
                                "products_weight"           : 1200.0,
                                "bullion_weight_available"  : 4000.0
                            },                      

                            "spot_rate" : {
                                "url"                       : "https://metals-api.com/",
                                "unit"                      : "gram",
                                "quality"                   : "999",
                                "api_name"                  : "metals-api",
                                "currency"                  : "USD",
                                "updated_at"                : "2026-01-16T06:00:00Z",
                                "current_rate"              : 3100.45
                            },                      

                            "media_library" : [
                                {
                                    "url"                   : "https://example.com/images/platinum_front.jpg",
                                    "description"           : "Front view of Platinum Bar",
                                    "uploaded_at"           : "2024-05-20T09:15:00Z"
                                },
                                {
                                    "url"                   : "https://example.com/images/platinum_side.jpg",
                                    "description"           : "Side view of Platinum Bar",
                                    "uploaded_at"           : "2024-05-22T11:45:00Z"
                                }
                            ]
                        }' AS JSON);

INSERT INTO tradable_assets
SET
    asset_name                      = 'PLATINUM',
    short_name                      = 'platinum',
    asset_code                      = 'PT',
    asset_intl_code                 = 'XPT',
    asset_type                      = 'METAL',
    forex_code                      = 'XPT',
    available_to_customers          = FALSE,
    tradable_assets_json            = fillTemplate(@metal_type_platinum, getTemplate('tradable_assets')),
    row_metadata                    = getTemplate('row_metadata');

-- ===============================================
-- ASSET TYPE: CASH
-- ===============================================

SET @cash_usd = CAST('{
                       "tradable_assets_rec_id"       : 4,
                       "asset_name"                   : "CASH",
                       "short_name"                   : "cash",
                       "asset_code"                   : "csh",
                       "asset_intl_code"              : "USD",
                       "wallet_type"                  : "CASH",
                       "forex_code"                   : "USD",
                       "available_to_customers"       : true,

                       "how_to_measure"               : "by_unit",
                       "standard_units"               : "USD",
                       "min_order"                    : 1.0,
                       "max_order"                    : 1000000.0,
                       "minimum_reedem_level"         : "1",
                       "max_reedem_level"             : "100000",

                       "taxes" : {
                           "GST"                       : "0%",
                           "Luxury_Tax"                : "0%",
                           "Import_Duty"               : "0%",
                           "withholding_tax"           : "0%"
                       },

                       "stats" : {
                           "products_weight"           : 0.0,
                           "bullion_weight_available"  : 0.0
                       },

                       "spot_rate" : {
                           "url"                       : "https://forex-api.com/",
                           "unit"                      : "USD",
                           "quality"                   : "1 USD",
                           "api_name"                  : "forex-api",
                           "currency"                  : "USD",
                           "updated_at"                : "2026-01-16T06:00:00Z",
                           "current_rate"              : 1.0
                       },

                       "media_library" : [
                           {
                               "url"                   : null,
                               "description"           : null,
                               "uploaded_at"           : null
                           }
                       ]
                    }' AS JSON);

INSERT INTO tradable_assets
SET
    asset_name                       = 'CASH',
    short_name                       = 'usd',
    asset_code                       = 'USD',
    asset_intl_code                  = 'USD',
    asset_type                       = 'CASH',
    forex_code                       = 'USD',
    available_to_customers           = TRUE,
    tradable_assets_json            = fillTemplate(@cash_usd, getTemplate('tradable_assets')),
    row_metadata                     = getTemplate('row_metadata');


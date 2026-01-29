-- ===============================================
-- ASSET RATE HISTORY INSERTS
-- ===============================================


-- ===============================================
-- ASSET RATE: METAL - GOLD
-- ===============================================

SET @asset_rate_gold = CAST(
                        '{
                            "asset_rate_rec_id"            : 1,
                            "tradable_assets_rec_id"       : 1,
                            "asset_code"                   : "GLD",

                            "spot_rate"                    : 4433.85,
                            "weight_unit"                  : "gram",
                            "currency_unit"                : "USD",

                            "rate_timestamp"               : "2026-01-16T06:00:00Z",
                            "effective_date"               : "2026-01-16",
                            "valid_until"                  : "2026-01-17",

                            "source_info" : {
                                "source_url"               : "https://metals-api.com/",
                                "rate_source"              : "metals-api",
                                "market_status"            : "Open",
                                "update_frequency"         : "Daily"
                            },

                            "foreign_exchange" : {
                                "foreign_exchange_rate"    : 278.50,
                                "foreign_exchange_source"  : "OpenExchange"
                            }
                        }'
                    AS JSON);

INSERT INTO asset_rate_history
SET
    tradable_assets_rec_id      = 1,
    asset_code                  = 'GLD',
    asset_rate_history_json     = fillTemplate(
												@asset_rate_gold,
												getTemplate('asset_rate_history')
											  ),
    row_metadata                = castJson('row_metadata');



-- ===============================================
-- ASSET RATE: METAL - SILVER
-- ===============================================

SET @asset_rate_silver = CAST(
                        '{
                            "asset_rate_rec_id"            : 2,
                            "tradable_assets_rec_id"       : 2,
                            "asset_code"                   : "SLV",

                            "spot_rate"                    : 55.32,
                            "weight_unit"                  : "gram",
                            "currency_unit"                : "USD",

                            "rate_timestamp"               : "2026-01-16T06:00:00Z",
                            "effective_date"               : "2026-01-16",
                            "valid_until"                  : "2026-01-17",

                            "source_info" : {
                                "source_url"               : "https://metals-api.com/",
                                "rate_source"              : "metals-api",
                                "market_status"            : "Open",
                                "update_frequency"         : "Daily"
                            },

                            "foreign_exchange" : {
                                "foreign_exchange_rate"    : 278.50,
                                "foreign_exchange_source"  : "OpenExchange"
                            }
                        }'
                    AS JSON);

INSERT INTO asset_rate_history
SET
    tradable_assets_rec_id      = 2,
    asset_code                  = 'SLV',
    asset_rate_history_json     = fillTemplate(
												@asset_rate_silver,
												getTemplate('asset_rate_history')
											  ),
    row_metadata                = castJson('row_metadata');



-- ===============================================
-- ASSET RATE: METAL - PLATINUM
-- ===============================================

SET @asset_rate_platinum = CAST(
                        '{
                            "asset_rate_rec_id"            : 3,
                            "tradable_assets_rec_id"       : 3,
                            "asset_code"                   : "PT",

                            "spot_rate"                    : 3100.45,
                            "weight_unit"                  : "gram",
                            "currency_unit"                : "USD",

                            "rate_timestamp"               : "2026-01-16T06:00:00Z",
                            "effective_date"               : "2026-01-16",
                            "valid_until"                  : "2026-01-17",

                            "source_info" : {
                                "source_url"               : "https://metals-api.com/",
                                "rate_source"              : "metals-api",
                                "market_status"            : "Open",
                                "update_frequency"         : "Daily"
                            },

                            "foreign_exchange" : {
                                "foreign_exchange_rate"    : 278.50,
                                "foreign_exchange_source"  : "OpenExchange"
                            }
                        }'
                    AS JSON);

INSERT INTO asset_rate_history
SET
    tradable_assets_rec_id      = 3,
    asset_code                  = 'PT',
    asset_rate_history_json     = fillTemplate(
												@asset_rate_platinum,
												getTemplate('asset_rate_history')
											  ),
    row_metadata                = castJson('row_metadata');



-- ===============================================
-- ASSET RATE: CURRENCY - USD
-- ===============================================

SET @asset_rate_usd = CAST(
                        '{
                            "asset_rate_rec_id"            : 4,
                            "tradable_assets_rec_id"       : 4,
                            "asset_code"                   : "USD",

                            "spot_rate"                    : 1.0,
                            "weight_unit"                  : "USD",
                            "currency_unit"                : "USD",

                            "rate_timestamp"               : "2026-01-16T06:00:00Z",
                            "effective_date"               : "2026-01-16",
                            "valid_until"                  : "2026-01-17",

                            "source_info" : {
                                "source_url"               : "https://forex-api.com/",
                                "rate_source"              : "forex-api",
                                "market_status"            : "Open",
                                "update_frequency"         : "Daily"
                            },

                            "foreign_exchange" : {
                                "foreign_exchange_rate"    : 1.0,
                                "foreign_exchange_source"  : "OpenExchange"
                            }
                        }'
                    AS JSON);

INSERT INTO asset_rate_history
SET
    tradable_assets_rec_id      = 4,
    asset_code                  = 'USD',
    asset_rate_history_json     = fillTemplate(
												@asset_rate_usd,
												getTemplate('asset_rate_history')
											  ),
    row_metadata                = castJson('row_metadata');

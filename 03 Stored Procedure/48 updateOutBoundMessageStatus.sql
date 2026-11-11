DROP PROCEDURE IF EXISTS updateOutboundMessageStatus;

CREATE PROCEDURE updateOutboundMessageStatus(
                                                 IN     pjReqObj     JSON,
                                                 INOUT  pjResObj     JSON
                                            )
BEGIN

    /* ===================== Core Variables ===================== */
    
    DECLARE v_message_gui_id                VARCHAR(100);
    DECLARE v_current_status                VARCHAR(50);
    DECLARE v_delivery_status               VARCHAR(50);
    DECLARE v_outbound_msgs_json            JSON;
    DECLARE v_rows_affected                 INT;

    /* ===================== Validation Variables ===================== */
    
    DECLARE v_error_message        TEXT;

    /* ===================== Error Handler ===================== */
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET STACKED DIAGNOSTICS CONDITION 1 v_error_message = MESSAGE_TEXT;

        SET pjResObj = JSON_OBJECT(
                                    'status',       'error',
                                    'message',      'Updating outbound message status failed',
                                    'system_error', v_error_message
                                   );
    END;

    /* ===================== Main ===================== */
    
    main_block: BEGIN

        /* ===================== Extract and Set Parameters ===================== */
        
        SET v_message_gui_id                = getJval(pjReqObj, 'jData.P_MESSAGE_GUI_ID');
        SET v_current_status                = getJval(pjReqObj, 'jData.P_CURRENT_STATUS');
        SET v_delivery_status               = getJval(pjReqObj, 'jData.P_DELIVERY_STATUS');
          

        /* ===================== Validations ===================== */

        IF isFalsy(v_message_gui_id) THEN
            SET pjResObj = buildJSONSmart(pjResObj, 'jHeader.responseCode', 1);
            SET pjResObj = buildJSONSmart(pjResObj, 'jHeader.message', 'P_MESSAGE_GUI_ID is required!');
            LEAVE main_block;
        END IF;

        IF isFalsy(v_current_status) AND isFalsy(v_delivery_status) THEN
            SET pjResObj = buildJSONSmart(pjResObj, 'jHeader.responseCode', 1);
            SET pjResObj = buildJSONSmart(pjResObj, 'jHeader.message', 'At least one status (P_CURRENT_STATUS or P_DELIVERY_STATUS) is required!');
            LEAVE main_block;
        END IF;

        /* ===================== Update Outbound Message Status ===================== */

        SELECT outbound_msgs_json
        INTO   v_outbound_msgs_json
        FROM   outbound_msgs
        WHERE  message_gui_id   = v_message_gui_id;

        SET  v_outbound_msgs_json = buildJSONSmart(v_outbound_msgs_json, 'lifecycle_status.current_status',  v_current_status);
        SET  v_outbound_msgs_json = buildJSONSmart(v_outbound_msgs_json, 'lifecycle_status.delivery_status', v_delivery_status);

        UPDATE  outbound_msgs
        SET     current_status                  = IFNULL(v_current_status, current_status),
                outbound_msgs_json              = v_outbound_msgs_json
        WHERE   message_gui_id                  = v_message_gui_id;

        /* ===================== Check if update was successful ===================== */

        SET v_rows_affected = ROW_COUNT();

        IF v_rows_affected = 0 THEN
            SET pjResObj = buildJSON(pjResObj, 'jHeader.responseCode', 2);
            SET pjResObj = buildJSON(pjResObj, 'jHeader.message', 'No outbound message found with the provided ID!');
            LEAVE main_block;
        END IF;

        /* ===================== Success Response ===================== */

        SET pjResObj = buildJSON(pjResObj, 'jHeader.responseCode',      0);
        SET pjResObj = buildJSON(pjResObj, 'jHeader.message',           'Outbound message status updated successfully.');

    END main_block;

    -- insert general code here like LOG
    -- call log proc

END
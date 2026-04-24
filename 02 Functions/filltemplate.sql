-- ==================================================================================================
-- Procedure: 			fillTemplate
-- Purpose:   			fill the template json with values from request object
--                     UPDATED: Now recursively merges nested objects using mergeJsonObjects
--                     Preserves all template structure while updating with request values
--                     Uses buildJSONSmart for proper value type detection and path handling
-- ===================================================================================================

DELIMITER $$

CREATE FUNCTION fillTemplate(
    pjReqObj     JSON,
    pjTemplateObj JSON
) 
RETURNS JSON
DETERMINISTIC
BEGIN
    -- Delegate to mergeJsonObjects for intelligent recursive merging
    -- This preserves all template fields while updating with request values
    RETURN mergeJsonObjects(pjTemplateObj, pjReqObj);
END $$

DELIMITER ;


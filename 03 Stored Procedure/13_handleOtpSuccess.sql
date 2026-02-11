-- ==================================================================================================
-- Procedure:   handleOtpSuccess
-- Purpose:     Execute business logic after successful OTP verification
-- ==================================================================================================

DROP PROCEDURE IF EXISTS handleOtpSuccess;

DELIMITER $$

CREATE PROCEDURE handleOtpSuccess(
									IN pContactType    ENUM('email','phone','loginid'),
									IN pDestination    VARCHAR(255),
                                    IN pPurpose        VARCHAR(100)
								)
BEGIN

    DECLARE v_login_id   VARCHAR(100);

    main_block: BEGIN

        CASE pPurpose

            -- =====================================================
            -- FORGOT LOGIN ID
            -- =====================================================
            WHEN 'FORGOT LOGIN ID' THEN

                SELECT user_name
                INTO   v_login_id
                FROM   customer
                WHERE  (email = pDestination OR phone = pDestination)
                LIMIT 1;

                IF v_login_id IS NOT NULL THEN

                    INSERT INTO outbound_msgs
                    (
                        channel,
                        recipient,
                        message_body,
                        created_at
                    )
                    VALUES
                    (
                        pContactType,
                        pDestination,
                        CONCAT('Your Login ID is: ', v_login_id),
                        NOW()
                    );

                END IF;

            -- =====================================================
            -- RESET PASSWORD (placeholder for future)
            -- =====================================================
            WHEN 'RESET PASSWORD' THEN
                -- Future implementation
               
               
               
                BEGIN END;

            -- =====================================================
            -- REGISTER (placeholder)
            -- =====================================================
            WHEN 'REGISTER' THEN
                BEGIN END;

            -- =====================================================
            -- DEFAULT (do nothing)
            -- =====================================================
            ELSE
                BEGIN END;

        END CASE;

    END main_block;

END $$

DELIMITER ;

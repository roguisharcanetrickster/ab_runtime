USE `appbuilder-admin`;

DROP PROCEDURE IF EXISTS `REPORT_INBOX_VALIDATE`;

DELIMITER $$
CREATE PROCEDURE `REPORT_INBOX_VALIDATE`
BEGIN
    DECLARE STATUS_QX_APPROVE_VALUE varchar(255) DEFAULT "1612340065524"; -- QX Approved

    -- Task ID - NOTE: Get from [process.gateway.exclusive] definition that name is 'Review Expense Report'
    DECLARE USER_FORM_TASK_ID varchar(255) DEFAULT "Task_14m1jfg";

    DECLARE PROCESS_ID varchar(255);
    DECLARE PROCESS_CONTEXT longtext;
    DECLARE PROCESS_CONTEXT_INPUT longtext;
    DECLARE PROCESS_CONTEXT_STATE longtext;
    DECLARE USER_FORM_CONTEXT longtext;
    DECLARE USER_FORM_ID varchar(255);
    DECLARE RUN_EXPENSE_REPORT_ID varchar(255);
    DECLARE PENDING_APPROVAL BOOLEAN DEFAULT FALSE;

    -- Get all pending Processes
    DECLARE done INT DEFAULT FALSE;
    DECLARE ALL_EXPENSE_REPORT_PROCESSES CURSOR FOR 
        SELECT `context`
        FROM `SITE_PROCESS_INSTANCE`
        WHERE
            `processID` = PROCESS_ID
            AND `created_at` >= DATE_SUB(NOW(), INTERVAL 3 MONTH)
            AND (`status` = "created")
        ORDER BY `created_at` DESC;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Pull ID of Expense Report Approval process
    SET PROCESS_ID := (SELECT `id`
                        FROM `appbuilder_definition`
                        WHERE `type` = "process"
                        AND `name` = "Expense Report Approval"
                        LIMIT 1);

    OPEN ALL_EXPENSE_REPORT_PROCESSES;
    read_loop: LOOP
        FETCH ALL_EXPENSE_REPORT_PROCESSES INTO PROCESS_CONTEXT;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SET PROCESS_CONTEXT_INPUT := JSON_EXTRACT(PROCESS_CONTEXT, '$.input');
        SET PROCESS_CONTEXT_STATE := JSON_EXTRACT(PROCESS_CONTEXT, '$.taskState');

        -- Extract ID of Expense Report row
        SET RUN_EXPENSE_REPORT_ID := JSON_UNQUOTE(JSON_EXTRACT(PROCESS_CONTEXT_INPUT, '$.uuid'));

        -- Lookup Expense Report row's Status
        SET PENDING_APPROVAL := (SELECT COUNT(`uuid`)
                        FROM `AB_DonationTracking_ExpenseReport`
                        WHERE `uuid` = RUN_EXPENSE_REPORT_ID
                        AND `Status` = STATUS_QX_APPROVE_VALUE) >= 1;

        IF PENDING_APPROVAL = FALSE
        THEN
            -- Pull ID of user form
            -- $.Task_06ytbzw.userFormID
            SET USER_FORM_CONTEXT := JSON_EXTRACT(PROCESS_CONTEXT_STATE, CONCAT('$.', USER_FORM_TASK_ID));
            SET USER_FORM_ID := JSON_UNQUOTE(JSON_EXTRACT(USER_FORM_CONTEXT, '$.userFormID'));

            IF USER_FORM_ID IS NOT NULL 
            AND USER_FORM_ID != "null"
            THEN
                -- Remove the process INBOX
                DELETE FROM `SITE_PROCESS_FORM`
                WHERE `uuid` = USER_FORM_ID;

                -- Remove the process INBOX
                DELETE FROM `AB_JOINMN_ProcessForm_USER_users`
                WHERE `ProcessForm` = USER_FORM_ID;

                -- Remove the process INBOX
                DELETE FROM `site`.`AB_JOINMN_ProcessForm_ROLE_roles`
                WHERE `ProcessForm` = USER_FORM_ID;
            END IF;
        END IF;

    END LOOP;
    CLOSE ALL_EXPENSE_REPORT_PROCESSES;

END$$
DELIMITER ;

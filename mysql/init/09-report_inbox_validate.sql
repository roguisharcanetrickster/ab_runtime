DROP PROCEDURE IF EXISTS `REPORT_INBOX_VALIDATE`;

DELIMITER $$
CREATE PROCEDURE `REPORT_INBOX_VALIDATE`()
BEGIN
    DECLARE EXPENSE_REPORT_PROCESS_ID varchar(255) DEFAULT 'cd9180a0-b3ea-4661-a5ea-8fa061ffe57b';
    DECLARE STATUS_QX_APPROVE_VALUE varchar(255) DEFAULT "1612340065524"; -- QX Approved

    SET SQL_SAFE_UPDATES = 0;

    DELETE f
    FROM
        `SITE_PROCESS_FORM` f
            INNER JOIN
        `AB_JOINMN_ProcessForm_USER_users` u ON f.`uuid` = u.`ProcessForm`
            LEFT JOIN
        `AB_DonationTracking_ExpenseReport` r ON r.`uuid` = (SELECT 
                JSON_UNQUOTE(JSON_EXTRACT(JSON_EXTRACT(`context`, '$.input'),
                                    '$.uuid'))
            FROM
                `SITE_PROCESS_INSTANCE`
            WHERE
                `uuid` = f.`process`
            LIMIT 1)
    WHERE
        (r.`uuid` IS NULL OR r.`Status` != STATUS_QX_APPROVE_VALUE) AND
        f.`status` = 'pending'
            AND f.`definition` = EXPENSE_REPORT_PROCESS_ID;

    SET SQL_SAFE_UPDATES = 1;

END$$
DELIMITER ;

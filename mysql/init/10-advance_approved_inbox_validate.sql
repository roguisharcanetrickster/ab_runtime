DROP PROCEDURE IF EXISTS `ADVANCE_APPROVED_INBOX_VALIDATE`;

DELIMITER $$
CREATE PROCEDURE `ADVANCE_APPROVED_INBOX_VALIDATE`()
BEGIN
    DECLARE ADVANCE_APPROVAL_PROCESS_ID varchar(255) DEFAULT '07da1422-31ea-4db3-8952-869d291827c9';
    DECLARE STATUS_PENDING_VALUE varchar(255) DEFAULT "1594172696999"; -- Pending

    SET SQL_SAFE_UPDATES = 0;

    DELETE f
    FROM
        `SITE_PROCESS_FORM` f
            INNER JOIN
        `AB_JOINMN_ProcessForm_USER_users` u ON f.`uuid` = u.`ProcessForm`
            LEFT JOIN
        `AB_DonationTracking_Advance` a ON a.`uuid` = (SELECT 
                JSON_UNQUOTE(JSON_EXTRACT(JSON_EXTRACT(`context`, '$.input'),
                                    '$.uuid'))
            FROM
                `SITE_PROCESS_INSTANCE`
            WHERE
                `uuid` = f.`process`
            LIMIT 1)
    WHERE
        (a.`uuid` IS NULL OR a.`Status` != STATUS_PENDING_VALUE) AND
        f.`status` = 'pending'
            AND f.`definition` = ADVANCE_APPROVAL_PROCESS_ID;

    SET SQL_SAFE_UPDATES = 1;

END$$
DELIMITER ;

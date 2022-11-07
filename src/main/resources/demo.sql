-- 导出  表 esteel_erp_fund.bank_channel_code 结构
CREATE TABLE IF NOT EXISTS `bank_channel_code`
(
    `row_id`                 bigint(20),
    `channel_code`           varchar(2),
    `channel_code_name`      varchar(50),
    `bank_channel`           varchar(40),
    `company_name`           varchar(60),
    `enabled`                tinyint(1),
    `creator_id`             int(11),
    `creator_name`           varchar(60),
    `created_at`             datetime,
    `wu_bo_bank_upload_code` varchar(100)
) DISTRIBUTED BY HASH(row_id) BUCKETS 2 PROPERTIES ("replication_num" = "1");

-- 数据导出被取消选择。

-- 导出  表 esteel_erp_fund.deposit_release 结构
CREATE TABLE IF NOT EXISTS `deposit_release`
(
    `row_id`               bigint(20),
    `release_id`           varchar(40),
    `sale_contract_code`   varchar(40),
    `release_price`        decimal(16, 2),
    `customer_id`          bigint(20),
    `customer_name`        varchar(60),
    `dept_id`              bigint(20),
    `dept_name`            varchar(60),
    `release_check_status` tinyint(4),
    `notes`                varchar(120),
    `creator_id`           varchar(30),
    `creator_name`         varchar(60),
    `created_at`           datetime,
    `modifier_id`          varchar(30),
    `modifier_name`        varchar(60),
    `modified_at`          datetime,
    `org_id`               bigint(20),
    `org_name`             varchar(50),
    `staff_id`             bigint(20),
    `staff_name`           varchar(50)
) DISTRIBUTED BY HASH(row_id) BUCKETS 2 PROPERTIES ("replication_num" = "1");

-- 导出  表 esteel_erp_fund.fund_flow 结构
CREATE TABLE IF NOT EXISTS `fund_flow`
(
    `row_id`                 bigint(20),
    `fund_flow_no`           varchar(40),
    `biz_no`                 varchar(100),
    `pay_or_receive_no`      varchar(40),
    `payment_no`             varchar(100),
    `receive_no`             varchar(100),
    `trans_out_company_name` varchar(60),
    `trans_out_company_id`   varchar(20),
    `fund_flow_type`         tinyint(4),
    `amount`                 decimal(16, 2),
    `bill_no`                varchar(40),
    `fund_direction`         varchar(8),
    `trans_time`             datetime,
    `trans_summary`          varchar(60),
    `trans_currency_type`    varchar(8),
    `purchase_sale_fee`      varchar(8),
    `org_id`                 int(11),
    `org_name`               varchar(60),
    `creator_id`             int(11),
    `creator_name`           varchar(60),
    `created_at`             datetime,
    `modifier_id`            int(11),
    `modifier_name`          varchar(60),
    `modified_at`            datetime,
    `origin`                 varchar(20)
) DISTRIBUTED BY HASH(row_id) BUCKETS 2 PROPERTIES ("replication_num" = "1");

-- 数据导出被取消选择。

-- 导出  表 esteel_erp_fund.fund_receive 结构
CREATE TABLE IF NOT EXISTS `fund_receive`
(
    `row_id`                   bigint(20),
    `receive_biz_no`           varchar(40),
    `trans_biz_id`             varchar(40),
    `receive_type`             varchar(8),
    `amount`                   decimal(16, 2),
    `amount_locked`            decimal(16, 2),
    `amount_used`              decimal(16, 2),
    `amount_available`         decimal(16, 2),
    `receive_status`           varchar(8),
    `receive_time`             datetime,
    `trans_time`               datetime,
    `currency_type`            varchar(8),
    `trans_type`               varchar(8),
    `trans_out_company_id`     varchar(20),
    `trans_out_company_name`   varchar(60),
    `trans_out_bank_account`   varchar(100),
    `trans_out_bank_name`      varchar(100),
    `trans_out_open_bank_name` varchar(60),
    `trans_out_bank_id`        varchar(20),
    `trans_in_bank_account`    varchar(100),
    `trans_in_bank_name`       varchar(100),
    `trans_in_open_bank_name`  varchar(60),
    `trans_in_bank_Id`         varchar(20),
    `trans_serial_no`          varchar(40),
    `receive_note`             varchar(200),
    `reverse_note`             varchar(200),
    `trans_summary`            varchar(60),
    `org_id`                   int(11),
    `org_name`                 varchar(60),
    `department_id`            int(11),
    `department_name`          varchar(60),
    `staff_id`                 int(11),
    `staff_name`               varchar(60),
    `creator_id`               int(11),
    `creator_name`             varchar(60),
    `created_at`               datetime,
    `modifier_id`              int(11),
    `modifier_name`            varchar(60),
    `modified_at`              datetime,
    `origin`                   varchar(20)
) DISTRIBUTED BY HASH(row_id) BUCKETS 2 PROPERTIES ("replication_num" = "1");

-- 数据导出被取消选择。

-- 导出  表 esteel_erp_fund.fund_transfer 结构
CREATE TABLE IF NOT EXISTS `fund_transfer`
(
    `row_id`                 bigint(20),
    `transfer_biz_no`        varchar(40),
    `transfer_status`        varchar(8),
    `reverse_note`           varchar(200),
    `transfer_amount`        decimal(16, 2),
    `currency_type`          varchar(8),
    `transfer_type`          varchar(8),
    `transfer_time`          datetime,
    `transfer_summary`       varchar(60),
    `trans_out_company_id`   varchar(20),
    `trans_out_company_name` varchar(60),
    `attachment_infos`       text,
    `note`                   varchar(200),
    `org_id`                 int(11),
    `org_name`               varchar(60),
    `creator_id`             int(11),
    `creator_name`           varchar(60),
    `created_at`             datetime,
    `modifier_id`            int(11),
    `modifier_name`          varchar(60),
    `modified_at`            datetime,
    `origin`                 varchar(20)
) DISTRIBUTED BY HASH(row_id) BUCKETS 2 PROPERTIES ("replication_num" = "1");

-- 数据导出被取消选择。

-- 导出  表 esteel_erp_fund.fund_transfer_detail 结构
CREATE TABLE IF NOT EXISTS `fund_transfer_detail`
(
    `row_id`           bigint(20),
    `transfer_biz_no`  varchar(40),
    `receive_biz_no`   varchar(40),
    `bill_type`        varchar(8),
    `bill_no`          varchar(40),
    `amount`           decimal(16, 2),
    `currency_type`    varchar(8),
    `amount_locked`    decimal(16, 2),
    `amount_used`      decimal(16, 2),
    `amount_available` decimal(16, 2),
    `trans_time`       datetime,
    `transfer_note`    varchar(200),
    `org_id`           int(11),
    `org_name`         varchar(60),
    `department_id`    int(11),
    `department_name`  varchar(60),
    `staff_id`         int(11),
    `staff_name`       varchar(60),
    `creator_id`       int(11),
    `creator_name`     varchar(60),
    `created_at`       datetime,
    `modifier_id`      int(11),
    `modifier_name`    varchar(60),
    `modified_at`      datetime,
    `origin`           varchar(20)
) DISTRIBUTED BY HASH(row_id) BUCKETS 2 PROPERTIES ("replication_num" = "1");

-- 数据导出被取消选择。

-- 导出  表 esteel_erp_fund.fund_write_off_revocation 结构
CREATE TABLE IF NOT EXISTS `fund_write_off_revocation`
(
    `row_id`            bigint(20),
    `revocation_app_no` varchar(40),
    `biz_no`            varchar(40),
    `app_amount`        decimal(16, 2),
    `app_time`          datetime,
    `app_type`          tinyint(4),
    `company_id`        varchar(20),
    `company_name`      varchar(60),
    `attachment_infos`  text,
    `note`              varchar(200),
    `org_id`            bigint(20),
    `org_name`          varchar(100),
    `department_id`     int(11),
    `department_name`   varchar(60),
    `staff_id`          int(11),
    `staff_name`        varchar(60),
    `app_status`        tinyint(4),
    `creator_id`        int(11),
    `creator_name`      varchar(60),
    `created_at`        datetime,
    `modifier_id`       int(11),
    `modifier_name`     varchar(60),
    `modified_at`       datetime,
    `origin`            varchar(20)
) DISTRIBUTED BY HASH(row_id) BUCKETS 2 PROPERTIES ("replication_num" = "1");

-- 数据导出被取消选择。

-- 导出  表 esteel_erp_fund.fund_write_off_revocation_item 结构
CREATE TABLE IF NOT EXISTS `fund_write_off_revocation_item`
(
    `row_id`            bigint(20),
    `revocation_app_no` varchar(40),
    `write_off_biz_no`  varchar(40),
    `receive_biz_no`    varchar(40),
    `biz_no`            varchar(40),
    `bill_type`         tinyint(4),
    `app_amount`        decimal(16, 2),
    `trans_out_amount`  decimal(16, 2),
    `note`              varchar(200),
    `origin`            varchar(20)
) DISTRIBUTED BY HASH(row_id) BUCKETS 2 PROPERTIES ("replication_num" = "1");

-- 数据导出被取消选择。

-- 导出  表 esteel_erp_fund.payment 结构
CREATE TABLE IF NOT EXISTS `payment`
(
    `row_id`                  bigint(20),
    `payment_no`              varchar(40),
    `biz_no`                  varchar(40),
    `app_no`                  varchar(100),
    `payment_method`          varchar(8),
    `app_type`                tinyint(4),
    `payment_time`            datetime,
    `domestic_payment_amount` decimal(16, 2),
    `payment_amount`          decimal(16, 2),
    `out_amount`              decimal(16, 2),
    `payer_bank_id`           bigint(20),
    `payer_bank_account`      varchar(100),
    `payer_bank_name`         varchar(100),
    `payer_opening_bank_name` varchar(100),
    `payee_bank_account`      varchar(100),
    `payee_bank_name`         varchar(100),
    `payee_bank_id`           bigint(20),
    `payee_opening_bank_name` varchar(100),
    `payee_id`                bigint(20),
    `payee_name`              varchar(100),
    `bank_statement_No`       varchar(40),
    `currency_code`           varchar(8),
    `currency_name`           varchar(60),
    `exchange_rate`           decimal(16, 4),
    `org_id`                  bigint(20),
    `org_name`                varchar(100),
    `department_id`           bigint(20),
    `department_name`         varchar(100),
    `staff_id`                bigint(20),
    `staff_name`              varchar(60),
    `bill_no`                 varchar(40),
    `bill_deadline_date`      datetime,
    `note`                    varchar(200),
    `hedge_serial_No`         varchar(40),
    `hedge_note`              varchar(200),
    `attachment_infos`        text,
    `record_status`           tinyint(4),
    `creator_id`              bigint(20),
    `creator_name`            varchar(60),
    `created_at`              datetime,
    `modifier_id`             bigint(20),
    `modifier_name`           varchar(60),
    `modified_at`             datetime,
    `origin`                  varchar(20)
) DISTRIBUTED BY HASH(row_id) BUCKETS 2 PROPERTIES ("replication_num" = "1");

-- 数据导出被取消选择。

-- 导出  表 esteel_erp_fund.payment_application 结构
CREATE TABLE IF NOT EXISTS `payment_application`
(
    `row_id`                  bigint(20),
    `biz_no`                  varchar(40),
    `app_no`                  varchar(100),
    `app_type`                tinyint(4),
    `payment_method`          tinyint(4),
    `payment_num`             decimal(16, 4),
    `currency_code`           varchar(16),
    `currency_name`           varchar(64),
    `exchange_rate`           decimal(16, 4),
    `domestic_app_amount`     decimal(16, 2),
    `app_amount`              decimal(16, 2),
    `domestic_paid_amount`    decimal(16, 2),
    `paid_amount`             decimal(16, 2),
    `domestic_offset_amount`  decimal(16, 2),
    `offset_amount`           decimal(16, 2),
    `payee_name`              varchar(60),
    `payee_id`                bigint(20),
    `payee_bank_id`           bigint(20),
    `payee_bank_name`         varchar(100),
    `payee_opening_bank_name` varchar(100),
    `payee_bank_account`      varchar(100),
    `app_time`                datetime,
    `deadline_payment_date`   datetime,
    `app_status`              tinyint(4),
    `note`                    varchar(200),
    `org_id`                  bigint(20),
    `org_name`                varchar(100),
    `department_id`           bigint(20),
    `department_name`         varchar(100),
    `staff_id`                bigint(20),
    `staff_name`              varchar(60),
    `attachment_infos`        text,
    `creator_id`              bigint(20),
    `creator_name`            varchar(60),
    `created_at`              datetime,
    `modifier_id`             bigint(20),
    `modifier_name`           varchar(60),
    `modified_at`             datetime,
    `origin`                  varchar(20)
) DISTRIBUTED BY HASH(row_id) BUCKETS 2 PROPERTIES ("replication_num" = "1");

-- 数据导出被取消选择。

-- 导出  表 esteel_erp_fund.payment_application_item 结构
CREATE TABLE IF NOT EXISTS `payment_application_item`
(
    `row_id`      bigint(20),
    `app_no`      varchar(100),
    `fee_type`    varchar(20),
    `fee_code`    varchar(40),
    `app_amount`  decimal(16, 2),
    `paid_amount` decimal(16, 2),
    `origin`      varchar(20)
) DISTRIBUTED BY HASH(row_id) BUCKETS 2 PROPERTIES ("replication_num" = "1");

-- 数据导出被取消选择。

-- 导出  表 esteel_erp_fund.payment_use 结构
CREATE TABLE IF NOT EXISTS `payment_use`
(
    `row_id`           bigint(20),
    `app_type`         tinyint(4),
    `use_biz_no`       varchar(100),
    `payment_no`       varchar(40),
    `app_no`           varchar(100),
    `paid_amount`      decimal(16, 2),
    `paid_time`        datetime,
    `out_amount`       decimal(16, 2),
    `transfer_type`    tinyint(4),
    `bill_no`          varchar(40),
    `note`             varchar(255),
    `use_status`       tinyint(4),
    `org_id`           bigint(20),
    `org_name`         varchar(100),
    `department_id`    bigint(20),
    `department_name`  varchar(100),
    `staff_id`         bigint(20),
    `staff_name`       varchar(60),
    `creator_id`       bigint(20),
    `creator_name`     varchar(60),
    `created_at`       datetime,
    `modifier_id`      bigint(20),
    `modifier_name`    varchar(60),
    `modified_at`      datetime,
    `attachment_infos` text
) DISTRIBUTED BY HASH(row_id) BUCKETS 2 PROPERTIES ("replication_num" = "1");

-- 数据导出被取消选择。

-- 导出  表 esteel_erp_fund.payment_use_revocation 结构
CREATE TABLE IF NOT EXISTS `payment_use_revocation`
(
    `row_id`            bigint(20),
    `revocation_biz_no` varchar(100),
    `payment_no`        varchar(40),
    `bill_no`           varchar(40),
    `use_biz_no`        varchar(100),
    `app_type`          tinyint(4),
    `payment_method`    varchar(8),
    `payment_time`      datetime,
    `currency_code`     varchar(8),
    `out_amount`        decimal(16, 2),
    `org_id`            bigint(20),
    `org_name`          varchar(100),
    `department_id`     bigint(20),
    `department_name`   varchar(100),
    `staff_id`          bigint(20),
    `staff_name`        varchar(60),
    `note`              varchar(200),
    `attachment_infos`  text,
    `creator_id`        bigint(20),
    `creator_name`      varchar(60),
    `created_at`        datetime,
    `modifier_id`       bigint(20),
    `modifier_name`     varchar(60),
    `modified_at`       datetime
) DISTRIBUTED BY HASH(row_id) BUCKETS 2 PROPERTIES ("replication_num" = "1");

-- 数据导出被取消选择。

-- 导出  表 esteel_erp_fund.pt_bankstatement 结构
CREATE TABLE IF NOT EXISTS `pt_bankstatement`
(
    `bankStatementID` int(11),
    `txnTime`         datetime,
    `txnDrcr`         varchar(10),
    `txnAmt`          decimal(24, 2),
    `hisBal`          decimal(24, 2),
    `txnDesc`         varchar(100),
    `txnUsage`        varchar(200),
    `stmt`            varchar(100),
    `vouType`         varchar(10),
    `vouNo`           varchar(20),
    `oppAc`           varchar(50),
    `oppacName`       varchar(100),
    `oppbrName`       varchar(100),
    `remark`          varchar(200),
    `bookingDate`     varchar(10),
    `transCode`       varchar(10),
    `bankChannel`     varchar(100),
    `channelCode`     varchar(4),
    `valStatus`       int(11),
    `sysCompanyId`    int(11),
    `makeTime`        datetime,
    `memberName`      varchar(200),
    `listID`          varchar(30),
    `state`           int(11),
    `inputdate`       datetime,
    `keyType`         int(11),
    `keyID`           varchar(30),
    `isAdd`           tinyint(4),
    `oper`            varchar(20)
) DISTRIBUTED BY HASH(bankStatementID) BUCKETS 2 PROPERTIES ("replication_num" = "1");

-- 数据导出被取消选择。

-- 导出  表 esteel_erp_fund.purchase_refund 结构
CREATE TABLE IF NOT EXISTS `purchase_refund`
(
    `row_id`            bigint(20),
    `refund_biz_no`     varchar(40),
    `revocation_app_no` text,
    `transfer_biz_no`   text,
    `note`              varchar(200),
    `attachment_infos`  text,
    `org_id`            bigint(20),
    `org_name`          varchar(100),
    `creator_id`        bigint(20),
    `creator_name`      varchar(60),
    `created_at`        datetime,
    `modifier_id`       bigint(20),
    `modifier_name`     varchar(60),
    `modified_at`       datetime
) DISTRIBUTED BY HASH(row_id) BUCKETS 2 PROPERTIES ("replication_num" = "1");

-- 数据导出被取消选择。

-- 导出  表 esteel_erp_fund.receipt_notice 结构
CREATE TABLE IF NOT EXISTS `receipt_notice`
(
    `row_id`                      bigint(20),
    `trans_biz_id`                varchar(40),
    `trans_serial_no`             varchar(40),
    `trans_in_bank_account`       varchar(100),
    `trans_in_bank_name`          varchar(100),
    `trans_in_open_bank_name`     varchar(60),
    `trans_in_bank_Id`            varchar(20),
    `trans_out_company_name`      varchar(60),
    `trans_out_company_id`        varchar(20),
    `trans_out_bank_account`      varchar(100),
    `trans_out_bank_name`         varchar(100),
    `trans_out_open_bank_name`    varchar(60),
    `trans_out_bank_id`           varchar(20),
    `trans_amount`                decimal(16, 2),
    `exchange_rate`               decimal(16, 2),
    `domestic_trans_amount`       decimal(16, 2),
    `trans_date`                  date,
    `trans_time`                  datetime,
    `trans_note`                  varchar(200),
    `trans_summary`               varchar(60),
    `trans_amount_not_occupancy`  decimal(16, 2),
    `trans_amount_occupancy`      decimal(16, 2),
    `trans_currency_type`         varchar(8),
    `trans_type`                  varchar(8),
    `receipt_notice_company_name` varchar(60),
    `trans_status`                varchar(8),
    `reverse_serial_no`           varchar(40),
    `reverse_note`                varchar(200),
    `org_id`                      int(11),
    `org_name`                    varchar(60),
    `creator_id`                  int(11),
    `creator_name`                varchar(60),
    `created_at`                  datetime,
    `modifier_id`                 int(11),
    `modifier_name`               varchar(60),
    `modified_at`                 datetime,
    `origin`                      varchar(20),
    `attachment_infos`            text,
    `datas_source_channel`        varchar(10),
    `time_point_balance`          decimal(16, 2)
) DISTRIBUTED BY HASH(row_id) BUCKETS 2 PROPERTIES ("replication_num" = "1");

-- 数据导出被取消选择。

-- 导出  表 esteel_erp_fund.sale_contract_quota 结构
CREATE TABLE IF NOT EXISTS `sale_contract_quota`
(
    `row_id`                   bigint(20),
    `allotment_biz_no`         varchar(40),
    `allotment_type`           varchar(8),
    `sale_contract_no`         varchar(40),
    `allotment_amount`         decimal(16, 2),
    `trans_biz_id`             varchar(40),
    `allotment_status`         varchar(8),
    `allotment_time`           datetime,
    `currency_type`            varchar(8),
    `trans_out_company_name`   varchar(60),
    `trans_out_bank_account`   varchar(100),
    `trans_out_bank_name`      varchar(60),
    `trans_out_open_bank_name` varchar(60),
    `trans_out_bank_id`        varchar(20),
    `trans_out_company_id`     varchar(20),
    `trans_serial_no`          varchar(40),
    `reverse_serial_no`        varchar(40),
    `reverse_note`             varchar(200),
    `allotment_note`           varchar(200),
    `attachment_infos`         text,
    `org_id`                   int(11),
    `org_name`                 varchar(60),
    `department_id`            int(11),
    `department_name`          varchar(60),
    `staff_id`                 int(11),
    `staff_name`               varchar(60),
    `creator_id`               int(11),
    `creator_name`             varchar(60),
    `created_at`               datetime,
    `modifier_id`              int(11),
    `modifier_name`            varchar(60),
    `modified_at`              datetime
) DISTRIBUTED BY HASH(row_id) BUCKETS 2 PROPERTIES ("replication_num" = "1");

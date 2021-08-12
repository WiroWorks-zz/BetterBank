CREATE TABLE `betterbanksave` (
	`IBAN` VARCHAR(6) NULL DEFAULT '0' COLLATE 'utf8mb4_bin',
	`islem` VARCHAR(20) NULL DEFAULT '' COLLATE 'utf8mb4_bin',
	`neKadar` VARCHAR(20) NULL DEFAULT '' COLLATE 'utf8mb4_bin',
	`neZaman` VARCHAR(30) NULL DEFAULT '' COLLATE 'utf8mb4_bin',
	`kimden` VARCHAR(20) NULL DEFAULT '' COLLATE 'utf8mb4_bin'
)

CREATE TABLE `billing` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`senderIBAN` VARCHAR(40) NOT NULL COLLATE 'utf8mb4_bin',
	`senderName` VARCHAR(40) NOT NULL COLLATE 'utf8mb4_bin',
	`targetIBAN` VARCHAR(40) NOT NULL COLLATE 'utf8mb4_bin',
	`label` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_bin',
	`amount` INT(11) NOT NULL,
	`neZaman` VARCHAR(40) NOT NULL COLLATE 'utf8mb4_bin',
	`durum` VARCHAR(20) NOT NULL DEFAULT 'Beklemede' COLLATE 'utf8mb4_bin',
	PRIMARY KEY (`id`) USING BTREE
)

ALTER TABLE `users`
ADD COLUMN `IBAN` VARCHAR(6) NOT NULL DEFAULT '0'

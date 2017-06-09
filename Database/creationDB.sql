-- GENERATION DATABASE
--     This script creates an empty database.
--     Be careful because it overwrites the existing database
--
-- Copyright 2017 <Biagio Festa>


DROP TABLE IF EXISTS `OPTIMIZER_CONFIGURATION_TABLE`;
DROP TABLE IF EXISTS `RUNNING_APPLICATION_TABLE`;
DROP TABLE IF EXISTS `APPLICATION_PROFILE_TABLE`;
DROP TABLE IF EXISTS `OPT_SESSIONS_RESULTS`;

CREATE TABLE `APPLICATION_PROFILE_TABLE` (
  `application_id` VARCHAR(100) NOT NULL,
  `dataset_size` DOUBLE NOT NULL,
  `phi_mem` DOUBLE NOT NULL,
  `vir_mem` DOUBLE NOT NULL,
  `phi_core` INT NOT NULL,
  `vir_core` INT NOT NULL,
  `chi_0` DOUBLE NOT NULL,
  `chi_c` DOUBLE NOT NULL,
  PRIMARY KEY (`application_id`)
);

CREATE TABLE `RUNNING_APPLICATION_TABLE` (
  `application_session_id` VARCHAR(100) NOT NULL,
  `application_id` VARCHAR(100) NOT NULL,
  `dataset_size` DOUBLE NOT NULL,
  `submission_time` TIMESTAMP NOT NULL,
  `status` VARCHAR(100) NOT NULL,
  `ending_time` TIMESTAMP,
  PRIMARY KEY (`application_session_id`),
  FOREIGN KEY (`application_id`) REFERENCES `APPLICATION_PROFILE_TABLE`(`application_id`)
);
       
CREATE TABLE `OPTIMIZER_CONFIGURATION_TABLE` (
  `application_id` VARCHAR(100) NOT NULL,
  `dataset_size` DOUBLE NOT NULL,
  `deadline` DOUBLE NOT NULL,
  `num_cores_opt` INT NOT NULL,
  `num_vm_opt` INT NOT NULL,
  PRIMARY KEY (`application_id`,`dataset_size`, `deadline`),
  FOREIGN KEY (`application_id`) REFERENCES `APPLICATION_PROFILE_TABLE`(`application_id`)
);

CREATE TABLE `OPT_SESSIONS_RESULTS` (
   `opt_id` VARCHAR(1024) NOT NULL,
   `app_id` VARCHAR(100) NOT NULL,
   `nu` FLOAT,
   PRIMARY KEY(`opt_id`, `app_id`)
);


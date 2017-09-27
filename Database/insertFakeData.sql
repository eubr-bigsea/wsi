-- GENERATION DATABASE
--     This script creates some stub data rows
--
-- Copyright 2017 <Biagio Festa>

INSERT INTO `APPLICATION_PROFILE_TABLE` (
  `application_id`,
  `dataset_size`,
  `phi_mem`,
  `vir_mem`,
  `phi_core`,
  `vir_core`,
  `chi_0`,
  `chi_c`) VALUES ('Q26', 123, 123, 123, 123, 123, 123, 123),
                  ('Q52', 123, 123, 123, 123, 123, 123, 123);

INSERT INTO `RUNNING_APPLICATION_TABLE` (
  `application_session_id`,
  `application_id`,
  `dataset_size`,
  `submission_time`,
  `status`,
  `weight`,
  `deadline`)
    VALUES ('application_1483347394756_0', 'Q26', 123, CURRENT_TIMESTAMP, 'RUNNING', 3.14, 100),
           ('application_1483347394756_1', 'Q52', 123, CURRENT_TIMESTAMP, 'RUNNING', 3.14, 100);

INSERT INTO `OPTIMIZER_CONFIGURATION_TABLE` (
  `application_id`,
  `dataset_size`,
  `deadline`,
  `num_cores_opt`,
  `num_vm_opt`)
   VALUES ('Q26', 123, 100000, 88, 22), 
          ('Q26', 123, 1000000, 8, 2), 
          ('Q52', 123, 200000, 42, 11), 
          ('Q52', 123, 800000, 11, 3);
  

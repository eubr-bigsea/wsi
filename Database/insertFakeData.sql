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
  `chi_c`) VALUES ('query26', 1000, 28, 8, 4, 2, 18906.97517, 12945621.49),
                  ('query40', 1000, 56, 18, 4, 2, 38056.87096, 20224206.15),
                  ('query52', 1000, 28, 8, 4, 2, 9474.291259, 10019343.23),
                  ('query55', 1000, 56, 18, 4, 2, 10137.70356, 9932642.77);

INSERT INTO `RUNNING_APPLICATION_TABLE` (
  `application_session_id`,
  `application_id`,
  `dataset_size`,
  `submission_time`,
  `status`,
  `weight`,
  `deadline`,
  `num_cores`)
    VALUES ('application_1483347394756_0', 'query26', 1000, '2017-01-01 00:00:00', 'RUNNING', 1, 200000, 4),
                   ('application_1483347394756_1', 'query52', 1000, '2017-01-01 00:00:00', 'RUNNING', 1, 100000, 4),
                   ('application_1483347394756_2', 'query40', 1000, '2017-01-01 00:00:00', 'RUNNING', 1, 1000000, 4),
           ('application_1483347394756_3', 'query55', 1000, '2017-01-01 00:00:00', 'RUNNING', 1, 100000, 4);

INSERT INTO `OPTIMIZER_CONFIGURATION_TABLE` (
  `application_id`,
  `dataset_size`,
  `deadline`,
  `num_cores_opt`,
  `num_vm_opt`)
   VALUES ('query40', 1000,  300000, 40, 10),
          ('query40', 1000, 1300000, 7, 2);

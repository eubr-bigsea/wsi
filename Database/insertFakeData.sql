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
  `status`)
    VALUES ('application_1483347394756_0', 'Q26', 123, CURRENT_TIMESTAMP, 'RUNNING'),
           ('application_1483347394756_1', 'Q52', 123, CURRENT_TIMESTAMP, 'RUNNING');

-- GENERATION DATABASE
--     This script insert preliminary bulma results
--
-- Copyright 2017 <Marco Lattuad>

INSERT INTO `OPTIMIZER_CONFIGURATION_TABLE` (
  `application_id`,
  `dataset_size`,
  `deadline`,
  `num_cores_opt`,
  `num_vm_opt`)
   VALUES ('bulma', 5, 695000, 45, 23),
          ('bulma', 5, 912500, 23, 12),
          ('bulma', 5, 1130000, 16, 8);

INSERT INTO `OPTIMIZER_CONFIGURATION_TABLE` (
  `application_id`,
  `dataset_size`,
  `deadline`,
  `num_cores_opt`,
  `num_vm_opt`)
   VALUES ('bulma_br', 5, 448000, 26, 13),
          ('bulma_br', 5, 473000, 22, 8),
          ('bulma_br', 5, 528484, 16, 8),
          ('bulma_br', 5, 625000, 12, 6),
          ('bulma_br', 5, 723000, 8, 4),
          ('bulma_br', 5, 1213400, 4, 2);

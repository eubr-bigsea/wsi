-- GENERATION DATABASE
--     This script insert preliminary bulma results
--
-- Copyright 2017 <Biagio Festa>

INSERT INTO `OPTIMIZER_CONFIGURATION_TABLE` (
  `application_id`,
  `dataset_size`,
  `deadline`,
  `num_cores_opt`,
  `num_vm_opt`)
   VALUES ('bulma', 5, 695000, 45, 23),
          ('bulma', 5, 912500, 23, 12),
          ('bulma', 5, 1130000, 16, 8);

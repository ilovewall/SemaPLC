# ST Baseline Ground-Truth Gaps

This file records known gaps between the control narratives/configuration and the publicly reviewed
`fbd-baseline` source used to generate `st-baseline`.

`fbd-baseline` is the ground truth for this directory. `fbd-GPT5-generated` may be useful as a
reference, but it is model output and must not be treated as reviewed benchmark truth.

| Plant | Missing section | Reason | Benchmark handling |
| --- | --- | --- | --- |
| benzene-distillation | Section5 / chapter_5 | `chapter_5` exists in the narrative and process config, but no reviewed `fbd-baseline/benzene-distillation/chapter_5` is published. | Exclude from ground-truth section tests until a reviewed baseline is added. |
| tennessee-eastman-chemical | Section6/chapter_6, Section10/chapter_10 | `chapter_6` and `chapter_10` exist in `fbd-GPT5-generated`, but no reviewed `fbd-baseline` chapters are published. | Exclude from ground-truth section tests until reviewed baselines are added. |
| waste_water_treatment_facility | Section3/chapter_3, Section5/chapter_5, Section6/chapter_6, Section8/chapter_8 | These chapters exist in `fbd-GPT5-generated`, but no reviewed `fbd-baseline` chapters are published. | Exclude from ground-truth section tests until reviewed baselines are added. |

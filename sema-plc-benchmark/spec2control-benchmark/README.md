# Spec2Control Dataset

65 section-level tasks across 10 industrial plants, based on
[Spec2Control](https://github.com/hkoziolek/Spec2Control).

| Path | Contents |
| --- | --- |
| `data/fbd-baseline/<plant>/chapter_N/` | Upstream specifications, interfaces and reference control logic |
| `data/st-baseline/<plant>/` | Project-derived reference ST programs and shared function blocks |
| `oracles/` | Frozen static-rule assertions for `smoke-5`, `medium-20` and `full-65` |
| `subsets/` | Task IDs for those subsets and `full-65-delta` |

A task such as `spec2control/benzene-distillation/section2` corresponds to
`data/fbd-baseline/benzene-distillation/chapter_2/0_cn_chapter.txt` and the reference
`data/st-baseline/benzene-distillation/pous/programs/Section2.st`.
The task is to implement the described control logic as `PROGRAM Section2`,
using the available function-block interfaces.

Expose the specification and allowed interfaces as task inputs. Keep
`2_control_logic.txt`, reference program implementations and oracles evaluator-side.
Oracle JSON contains static checks such as required calls, constants and text
patterns; it does not by itself prove runtime behavior. Its `source` fields
record provenance and can mention development tests not distributed here.

ST references, oracles and section subsets are project-derived additions, not
an official upstream scoring standard. This directory contains no evaluator,
conversion scripts or runtime simulation variants. Known missing reference
sections are documented in [BASELINE_GAPS.md](data/st-baseline/BASELINE_GAPS.md).

See [provenance and changes](data/NOTICE-Spec2Control.md) and the
[upstream Apache-2.0 license](data/LICENSE-Spec2Control).

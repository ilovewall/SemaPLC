# Agents4PLC Dataset

117 independent-POU tasks from [Agents4PLC](https://github.com/Luoji-zju/Agents4PLC_release).

| File | Tasks |
| --- | ---: |
| `v1_easy.jsonl` | 16 |
| `v1_medium.jsonl` | 7 |
| `v2_medium.jsonl` | 70 |
| `v2_hard.jsonl` | 3 |
| `v2_high_fidelity.jsonl` | 21 |

- `data/`: original dataset copy, with 629 verification properties.
- `data-fixed/`: revised requirements and properties, with 607 properties across
  the same 117 task IDs. A total of 53 tasks differ from the original copy.
- [COMPARISON_TABLE.md](data-fixed/COMPARISON_TABLE.md): task-level comparison.

Records contain `id`, `instruction` and `properties_to_be_validated`. Some also
contain `ground_truth` and `test_cases`; keep reference answers separate from
solver inputs. Choose one dataset version consistently for an experiment.

Despite the `.jsonl` suffix, files can contain concatenated, multiline JSON
objects. Use a streaming JSON decoder rather than assuming one object per line.
No evaluator or installation is provided in this data-only distribution.

See [provenance and changes](NOTICE-Agents4PLC.md) and the
[upstream Apache-2.0 license](LICENSE-Agents4PLC).

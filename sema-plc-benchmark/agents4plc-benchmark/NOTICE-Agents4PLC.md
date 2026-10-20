# Agents4PLC benchmark data — 出处与改动声明

`data/` 与 `data-fixed/` 下的 117 例 benchmark 数据源自 **Agents4PLC**
（<https://github.com/Luoji-zju/Agents4PLC_release>），上游许可为 **Apache License 2.0**，
全文见同目录 [`LICENSE-Agents4PLC`](LICENSE-Agents4PLC)。

论文：Agents4PLC: Automating Closed-loop PLC Code Generation and Verification in
Industrial Control Systems using LLM-based Agents（<https://arxiv.org/abs/2410.14209>）。

```bibtex
@article{liu2024agents4plc,
  title={Agents4plc: Automating closed-loop plc code generation and verification in industrial control systems using llm-based agents},
  author={Liu, Zihan and Zeng, Ruinan and Wang, Dongxia and Peng, Gengyun and Wang, Jingyi and Liu, Qiang and Liu, Peiyu and Wang, Wenhai},
  journal={arXiv preprint arXiv:2410.14209},
  year={2024}
}
```

## 各目录的来源

| 目录 | 来源 |
|---|---|
| `data/` | **上游数据集副本，本工作未改动其内容**：对应上游 `benchmark_v1/`、`benchmark_v2/` 下的 117 例，文件名平铺为 `v1_easy.jsonl` / `v1_medium.jsonl` / `v2_medium.jsonl` / `v2_hard.jsonl` / `v2_high_fidelity.jsonl`。本工作的全部修正都落在 `data-fixed/`，`data/` 自取用起未被触碰。 |
| `data-fixed/` | **本工作修正版**：在 `data/` 基础上逐条修正形式化属性中的缺陷，共改动 **53 个样本**。 |

## 改动说明（Apache-2.0 §4(b)）

`data-fixed/` 相对 `data/` 的修改类型包括：数值/变量名/极性错误更正、重言式与自相矛盾属性重构、缺失前提条件
补全、无题目依据的臆造阈值及重复属性删除，以及欠明确需求的补充说明。

逐样本前后对照见 `data-fixed/COMPARISON_TABLE.md`（53 行）。

`data/` 保持未被触碰（五个文件的 MD5 与取用时一致），可选择 `data/` 作为原始数据进行对照。本工作未随附上游的 `src/`、`evaluate/`、`simple-demo/`、`pics/` 等目录；
本目录不随附上游方法复现代码。

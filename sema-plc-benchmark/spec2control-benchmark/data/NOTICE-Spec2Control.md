# Spec2Control data — 出处与改动声明

本目录的数据源自 **Spec2Control**（<https://github.com/hkoziolek/Spec2Control>），
一个把控制叙述（control narrative）翻译成 IEC 61131-3 功能块图（FBD）的 LLM 工作流项目。
上游许可为 **Apache License 2.0**，全文见同目录 [`LICENSE-Spec2Control`](LICENSE-Spec2Control)。

## 各子目录的来源

| 子目录 | 来源 |
|---|---|
| `fbd-baseline/` | **上游原样取用**：Spec2Control 的人工审核 FBD 基线。 |
| `st-baseline/` | **本工作派生**：由数据转换流程从 `fbd-baseline/` 逐装置转换成 OpenPLC Editor v4 原生工程布局（`project.json` + `pous/*.st` + `devices/*`），转换依据每章的 `2_control_logic.txt`。 |

`../oracles/` 与 `../subsets/` 中的项目新增材料
按本目录上层的 MIT 许可分发。

## 改动说明（Apache-2.0 §4(b)）

相对上游，本工作：

- 只取用了 `fbd-baseline/` 这一部分数据，未随附上游的 `control-narratives/`、
  `BASIC_LIB/`、`prompt-sets/`、`fbd-GPT5-generated/`、`fbd-llm-output/`、
  `experiment_results.xlsx` 与 `_evaluation-script-output/`；
- 将 FBD 基线转成 ST 参考程序（`st-baseline/`），
  以便在 OpenPLC 运行时上编译与执行；
- 在此基础上新增了 section 级的任务切分、oracle 数据。转换与评测脚本不在本次数据分发范围内。

上游未提供引用格式（无 paper / arXiv / DOI 声明），本工作以仓库地址标注出处。

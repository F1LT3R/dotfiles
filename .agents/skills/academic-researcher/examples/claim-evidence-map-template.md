# Claim-Evidence Map Template

| Claim | Strength | Evidence | Conditions | Caveats | Citations |
|-------|----------|----------|-----------|---------|----------|
| XAI-Care improves accuracy over baselines | Strong | Table 2: +3.1% accuracy on CheXpert | CheXpert dataset, ResNet backbone | Single dataset, single architecture | smith2023 |
| Concept explanations are clinically meaningful | Medium | Clinician survey (n=12, mean Likert 4.2/5) | Chest X-ray domain | Small sample, single hospital | smith2023 |
| Attention-based methods outperform gradient methods | Moderate | Ablation study: attention F1=0.87 vs Grad-CAM F1=0.79 | ImageNet-pretrained models | Only tested on classification tasks | jones2022 |
| Training time overhead is negligible | Weak | Reported <5% wall-clock increase, no CI given | Single GPU (A100), batch size 32 | No multi-GPU or CPU-only results | smith2023 |
| | | | | | |

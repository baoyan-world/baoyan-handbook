# 每日增量更新流程

本仓库以 21 个章节 Markdown 作为 GitHub 在线阅读正文；`tex/` 保存对应 PDF 工程。每次更新只新增或扩充必要内容，沿用已发布文件和来源编号，不覆盖历史版本。

## 更新步骤

1. **选题与查重**：从当届学生正在遇到的资格、志愿、复试、录取确认或入学问题中选题。先在 `docs/chapters/` 和 README 问答索引搜索关键词与近义问法；只在答案提供了新的规则边界、操作路径或风险说明时新增问题。
2. **核对证据**：政策和校规优先使用教育主管部门、研招网、省级机构及招生单位官网原文。逐条标出年份、适用届别、地区/院系范围；网页日期、系统窗口等易变信息注明核对日期，并在正文提醒复查当年页面。经验建议与硬性规定分开写。
3. **编辑章节双份正文**：在 `docs/chapters/chNN.md` 添加或扩充问答；在 `tex/chapters/chNN.tex` 同步相同标题、结论、步骤和引用。修改旧答前保留原有有效结论与来源。PDF 问答 ID 使用不重复的编号。
4. **追加来源**：`docs/references.md` 与 `tex/backmatter/sources.tex` 的数字来源编号只追加不重排。每个新引用都要有可访问的原始链接、发布机构、文件标题、年份和适用范围；TeX 中同时添加唯一的 `S` 标签，使正文可点击跳转。
5. **同步目录与计数**：更新 `tex/frontmatter/overview.tex` 中的总问答数和受影响章节计数；更新 `CHANGELOG.md`。运行 `python3 scripts/generate_readme_index.py` 生成问答索引，再运行 `python3 scripts/generate_readme_index.py --check` 确认索引与章节标题一致。
6. **编译新版本**：运行 `scripts/build-release.sh vX.Y.Z`。脚本拒绝覆盖已存在的版本目录，使用 XeLaTeX 和 makeindex 编译四遍，并在指定版本目录生成 PDF。
7. **交付核对**：用 `pdfinfo` 核对页数与文件大小，用 `pdftotext` 核对新旧内容和引用，用 `sha256sum` 记录文件哈希；验证 README、各章 PDF 链接和新增参考来源锚点。更新 README 当前版本、PDF 页数/大小、SHA-256 和更新摘要后再提交。

## 变更记录建议

每次发布在 `CHANGELOG.md` 记录：更新日期、旧/新问答数、新增问题数量、扩写旧答数量及标题示例、旧/新 PDF 页数、来源编号范围、文件 SHA-256。仅当 PDF、章节 Markdown、来源表、README 索引和计数相互一致时才发布。

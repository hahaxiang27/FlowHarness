<!--
SYNC IMPACT REPORT — TEMPLATE
============================================
Version: 0.1.0  [domain profile template, awaiting first ratification]
Domain: cn-control-plane（5G 核心网控制面 / SBI 服务化网元）
Source: 2026-05-04 抽象自 AISware AgileNet-CN NRF 项目 Constitution v0.1.0

适用项目：5G 核心网控制面网元（NF Repository Function / Access and Mobility Management Function /
Session Management Function / Unified Data Management / Authentication Server Function /
Policy Control Function / Network Slice Selection Function 等所有 SBI 化的 NF）。

不适用项目：
- 用户面 NF（UPF）：因涉及高速数据转发，应使用 ran-baseband 或专用 user-plane profile
- RAN 网元：使用 ran-baseband profile
- 通用 Web/SaaS：使用 web-saas profile

填充指引（[占位] 标记必填）：
1. 项目名：替换 [PROJECT_NAME]
2. 项目代号：替换 [PROJECT_CODENAME]（如 AISware AgileNet-CN NRF）
3. 核心 NF 类型：替换 [NF_TYPE]（如 NRF / AMF / SMF）
4. 协议规范号：根据 NF 类型替换 [TS_CORE_SPEC]（如 NRF=29.510 / AMF=29.518 / SMF=29.502）
5. 性能基线：根据网络规划替换 [P95_LATENCY_*] 占位值（保留示例值供参考）
6. 默认 Release：根据运营商要求选择（默认 R17）

Templates requiring follow-up after ratification:
  ⚠️ .specify/templates/spec-template.md  — 验证 SBI/性能/安全段是否需要 cn-control-plane 扩展
  ⚠️ .specify/templates/plan-template.md  — 验证 Scope 边界验证清单引用
  ✅ .specify/templates/tasks-template.md — 未引用具体编号 · 无需更新
-->

# [PROJECT_NAME] Constitution

本宪法是 [PROJECT_CODENAME]（5G 核心网 [NF_TYPE] 网元）项目所有 spec / plan / tasks / implement 阶段的非协商基线。下述原则与任何项目内规章冲突时以本宪法为准；本宪法与 3GPP / 运营商企业规范等外部协议冲突时以协议为准（见 Principle I）。

[NF_TYPE] 提供 5G 核心网控制面的 [NF_FUNCTIONAL_DESCRIPTION]，定义在 3GPP TS [TS_CORE_SPEC]，接口形态为 HTTP/2 + JSON over TLS 的 SBI（Service-Based Interface）。

## Core Principles

### I. 协议合规优先（NON-NEGOTIABLE）

**规则**

- 所有功能 MUST 可追溯到 3GPP 标准段落或运营商企业规范条目。基线协议族：
  - **3GPP TS 23.501**（5G 系统架构）
  - **3GPP TS 23.502**（5G 系统流程）
  - **3GPP TS 29.500**（5G SBI 框架）
  - **3GPP TS [TS_CORE_SPEC]**（[NF_TYPE] 服务化接口）—— **核心规范**
  - **3GPP TS 33.501**（5G 安全架构与流程）
  - **运营商 5G 核心网 [NF_TYPE] 设备规范**（项目交付基线，按需替换）
  - 推荐基线版本：**Release 17**（高于运营商最低要求即可）
- 协议、宪法、spec 三者发生冲突时，**以协议为准**。
- MUST NOT 在没有协议依据的情况下创造 SBI 行为或 NF profile / 业务字段；如确需协议外扩展，必须在 spec/plan 显式声明并标记为"私有协议扩展"，并提交 ADR。
- 凡 spec 中引用协议条款 MUST 给出明确章节号（如 "TS [TS_CORE_SPEC] §5.2.2.2.1"）；缺失即视为 MEDIUM 违规。

**理由**：核心网控制面 NF 之间互通是产品存在的底线。无协议依据的实现等于在 5GC 全网埋雷。

### II. SBI 服务化接口契约（NON-NEGOTIABLE）

**规则**

- SBI 接口契约（OpenAPI yaml，源自 3GPP TS）MUST 视为只读；任何变更只能由 spec 或设计需求**显式驱动**，并提交 ADR。
- MUST NOT 出现以下行为：
  - 私自扩展 NF profile / 业务实体字段
  - 私有错误码（必须在 3GPP 定义的错误码集合内）
  - 绕过 SBI 直连其他 NF 的内部接口
  - 改写共享数据结构的字段语义
- 在 plan 阶段，凡涉及对外 SBI 端点的特性必须显式列出 **接口字段引用清单**（哪些字段读、哪些字段写、哪些事件订阅）与**变更清单（若有）**。
- 内部模块之间的依赖必须经 `harness/scope/sprint-N.yaml` 声明；未声明的反向依赖即视为 NEW_VIOLATION。

**理由**：SBI 是 5GC 控制面的"通用语言"。任何 NF 的接口畸变都会被全网放大。契约稳定 = 网络稳定。

### III. SBI 接口延迟预算

**规则**

- 关键接口的 p95 延迟 MUST 不超过下述基线（在标称负载下）。**以下为参考基线，[PROJECT_NAME] 应按 NF 类型 + 网络规划调整**：

| 接口 | p95 延迟 | 备注 |
|---|---|---|
| 主要写操作（注册 / 创建 / 更新） | ≤ [P95_LATENCY_WRITE] ms（建议 ≤ 100 ms） | 含持久化 + TLS 握手摊销 |
| 主要读操作（查询 / 发现） | ≤ [P95_LATENCY_READ] ms（建议 ≤ 50 ms） | 含过滤 / 分页 |
| 心跳 / 健康检查 | ≤ [P95_LATENCY_HEARTBEAT] ms（建议 ≤ 50 ms） | 不含网络 RTT |
| 订阅事件通知 | ≤ [P95_LATENCY_NOTIF] ms（建议 ≤ 200 ms） | 端到端 |

- BBU/CPU 总占用率 MUST ≤ **70%**（峰值），≤ **60%**（稳态）。
- 每个新特性 MUST 在 plan 阶段给出**端到端时延预算分解**（含本特性新增计算、DB 访问、网络 RTT、TLS / 序列化开销），并在 implement 阶段提供实测证据。
- MUST NOT 以"灰度后再优化"为由把超预算的特性合入 main。

**理由**：5GC 控制面对延迟敏感。NF 慢一倍 = 全网注册/发现/切换都慢一倍。延迟预算是 SLA 的物理前提。

### IV. 测试纪律（NON-NEGOTIABLE）

**规则**

- 每条 `Deferrable: no` 的 SC MUST 提供 **5 类完整证据**：
  1. **测试用例**（明确 GIVEN/WHEN/THEN）
  2. **测试报告**（PASS/FAIL 结论 + 数据）
  3. **日志**（关键路径可抓取，含 traceId / requestId）
  4. **自动化结果**（CI/CD 或回归框架的 run 链接/制品）
  5. **评审记录**（同行/Lead 评审结论）
- 测试覆盖必须包含 **UT + 集成测试 + NF 互通测试** 三层（必选）：
  - **UT**：业务逻辑分支覆盖 ≥ 90%；字段验证 / 错误路径必测
  - **集成测试**：用 mock NF 客户端 + 真实例端到端，覆盖每条 acceptance scenario
  - **NF 互通测试**：与至少 1 款主流第三方对端 NF（含开源 free5GC / Open5GS / OpenAirInterface CN）跑互通；或与运营商指定的真实 NF 跑联调
- **协议一致性套件**（ETSI / Spirent / Keysight 或同类）：在条件成熟后纳入；当前阶段每个特性应说明其协议一致性验证路径。
- MUST NOT 用 "DEFERRED 到灰度" 作为绕过 `Deferrable: no` SC 的理由；亦不允许在 Sprint 收官前临时把 `Deferrable: no` 改为 `yes`。
- 每个 Sprint 收官 Checkpoint 必须按 SC 列表逐条核对 5 类证据，缺一不视为 PASS。

**理由**：核心网故障会被 5GC 放大成全网现象。证据链不齐 ≈ 在生产网络上裸奔。

### V. 可观测性是一等公民

**规则**

- 每个特性 MUST 暴露至少 **4 类指标**：
  1. **业务正确性**：成功率 / 拒绝率 / 关键业务事件计数
  2. **时延**：每个 SBI 端点的 p50 / p95 / p99
  3. **错误率**：HTTP 4xx/5xx 分类 / OAuth2 鉴权失败率 / TLS 握手错误率 / DB 错误率
  4. **资源占用**：CPU / 内存 / DB 连接池 / TLS session 缓存
- 关键指标 MUST 接入项目 telemetry 通道（最低底线：日志可抓取 + Prometheus 指标 + structured log with traceId）。
- SHOULD 提供告警阈值与运维 dashboard（建议 Grafana）；缺失时 plan 阶段必须说明替代手段。
- 跨 NF 调用 MUST 携带 W3C Trace Context / OpenTelemetry trace 头，使全链路可追踪。
- MUST NOT 交付"跑起来就完事但黑盒"的特性。

**理由**：5GC 故障定位的成本远高于地面网络（涉及多 NF 厂商、多机房、多版本）。可观测性是 SLA 的前提，不是事后追加项。

### VI. 安全合规（NON-NEGOTIABLE）

**规则**

- **TLS 1.2+** 全链路加密：所有 SBI 端点 MUST 强制 TLS（含 mTLS 选项），禁止 plaintext HTTP/2。
- **OAuth2 Client Credentials Flow（TS 33.501）** 强制：所有 NF 调用方必须出示有效 access token；本 NF MUST 校验 token 签名 / 过期 / scope / audience。
- **JWT 签名校验**：使用 RFC 7515 / 7519 标准；签名算法白名单（推荐 ES256 / RS256，禁止 none）；公钥获取走 JWKS endpoint。
- **敏感字段处理**：业务实体中的认证凭据 / 内部 IP / 私钥相关字段 MUST 不在日志输出 / 不持久化到非加密存储 / API 响应必要时脱敏。
- **零明文凭据**：数据库密码 / 证书私钥 / OAuth2 client secret 一律走 secrets manager（vault / k8s secret）；代码 / 配置文件中零明文。
- **审计日志**：所有鉴权 / 关键业务事件 MUST 记入审计日志，含 source IP / requester NF instance ID / timestamp / 操作结果。
- MUST NOT 在 spec/plan 阶段把"安全后做"列为 P3；任何安全相关需求最低 P2，凡延期必须 ADR。

**理由**：核心网安全是国家关键信息基础设施合规要求。NF 一旦被仿冒或鉴权穿透，全网 NF 信任链崩塌。

### VII. 复用优先 · 拒绝 NIH

**规则**

- 特性实现 MUST 优先按以下顺序选择来源：
  1. **3GPP 参考实现 / OpenAPI 标准 codegen 产物**
  2. **业界成熟开源方案**（如 free5GC / Open5GS / OpenAirInterface CN 的实现思路）
  3. **项目现有基线代码**
  4. **新写**（最后选项）
- 智能体工程师 MAY 单方面判定"复用 vs 重写"，但 plan 文档 MUST 明确包含：
  - **候选清单**（至少 1 个复用候选 + 自研候选）
  - **决策依据**（性能 / 协议合规 / IP / 适配成本，至少一条具体理由）
  - **后果声明**（重写带来的额外维护成本承担方）
- MUST NOT 在没有 plan 决策记录的情况下重写已可用的代码或重新实现已有协议参考。
- OpenAPI codegen 产出的 stub / DTO MUST 不被人工改动（保留生成痕迹），改动只能改 codegen 模板或重新生成。

**理由**：5GC NF 是协议规范驱动的网元，标准化程度极高。重复造轮子等于把 IP 集中在内部代码而非运营商眼里的合规价值。

## 技术约束与性能标准

### 协议基线

| 项 | 取值 |
|---|---|
| 3GPP 基线 | Release 17（按运营商要求调整） |
| 核心规范 | TS [TS_CORE_SPEC]（[NF_TYPE] 服务化接口） |
| 安全规范 | TS 33.501（5G 安全架构）+ TLS 1.2+ + OAuth2 |
| OpenAPI 版本 | 3.0.x |
| HTTP 版本 | HTTP/2（强制） |
| 数据格式 | JSON（UTF-8） |

### 部署形态

| 项 | 取值 |
|---|---|
| 部署模式 | 容器化 NF（K8s / VM 均支持） |
| 实现语言 | （由 plan 阶段选定 · 候选：Java + Spring Boot / Go / 其他符合协议合规的栈） |
| 持久化 | PostgreSQL 14+ 或 etcd 3.5+（小规模）；plan 阶段决策 |
| 副本与一致性 | 至少 2 副本主备；plan 阶段评估强一致 vs 最终一致 |
| 中间件 | 优先采用基线现有中间件 / 业界成熟中间件，禁止无理由自研 |

### 性能基线

按 NF 类型与网络规划填充。以下为典型 SBI NF 的参考基线：

| 项 | 上限 / 目标 |
|---|---|
| 主要写操作 p95 延迟 | ≤ [P95_LATENCY_WRITE] ms |
| 主要读操作 p95 延迟 | ≤ [P95_LATENCY_READ] ms |
| 心跳 p95 延迟 | ≤ [P95_LATENCY_HEARTBEAT] ms |
| 订阅通知端到端时延 p95 | ≤ [P95_LATENCY_NOTIF] ms |
| 标称负载 | [QPS_NOMINAL] QPS（持续）/ [QPS_PEAK] QPS（峰值 60s） |
| 标称并发 | [CONCURRENT_PEERS] 个对端 NF |
| CPU 占用 | ≤ 70%（峰值）/ ≤ 60%（稳态） |
| TLS 握手错误率 | < 0.1%（健康环境） |
| OAuth2 鉴权拒绝率 | 100%（对未授权请求） |

### 安全基线

| 项 | 要求 |
|---|---|
| TLS 版本 | 1.2+（推荐 1.3） |
| 密码套件 | ECDHE + AES-GCM 系列；禁用 RC4 / DES / 3DES / 静态 DH |
| OAuth2 流程 | Client Credentials Grant（TS 33.501） |
| Token 类型 | JWT；签名算法 ES256 / RS256；禁用 none |
| Token 过期 | 默认 1h；refresh token 不强制 |
| 审计日志保留 | ≥ 180 天（按运营商要求） |

## 开发工作流与质量门

### Sprint 节奏

- Sprint 周期：**2 周**
- 归档目录：所有 Sprint 文档落入 `.harness/sprints/`，命名 `sprint-N.md` / `sprint-N-progress.md` / `sprint-N-checkpoint.md`
- 每个 Sprint 收官 MUST 跑一次 Constitution Check

### Checkpoint 机制

- Checkpoint 输出落入 `.harness/checkpoints/`
- Checkpoint 必须逐项核验：
  - 所有 `Deferrable: no` SC PASS（5 类证据齐全）
  - 延迟预算未超（实测 p95 含负载工况）
  - SBI 接口契约无违规（OpenAPI diff = 0 或仅 backward-compatible 扩展）
  - 安全规则无违规（TLS / OAuth2 / 敏感字段 / 审计日志）
  - 至少 4 类可观测性指标已暴露
- Checkpoint FAIL 的 Sprint MUST NOT 进入下一 Sprint，需先修复或走 Governance 例外。

### 代码评审

- **SBI 接口相关变更**（OpenAPI yaml / 业务实体字段 / 错误码 / 订阅事件）：架构组单独 sign-off + 至少一名一般评审者
- **安全相关变更**（TLS 配置 / OAuth2 / JWT / 敏感字段处理 / 审计日志）：安全组单独 sign-off + 至少一名一般评审者
- **一般变更**：双人评审（其中至少一人在 SBI / 5GC 协议层有经验）
- 任何评审者发现违反 Core Principles 必须 BLOCK 合入并发起例外申请（见 Governance）

### 接口变更评审

- SBI / OpenAPI / 业务实体 / 错误码集合变更 MUST 提交 ADR（位于 `specs/[feature]/contracts/` 或单独 `decisions/` 目录），并经架构组评审。
- ADR 必须包含：变更动机、协议依据（或私有协议扩展声明）、向后兼容策略、对其他 NF 的影响评估、回滚预案、版本号变化。

### 测试门

| 门 | 要求 | 当前是否强制 |
|---|---|---|
| UT 通过率 | 100% | ✅ 强制 |
| UT 业务分支覆盖 | ≥ 90% | ✅ 强制 |
| 集成测试 | 关键路径全覆盖（每条 acceptance scenario ≥ 1 case） | ✅ 强制 |
| 关键指标 | 至少 4 类可观测性指标可被运维抓取 | ✅ 强制 |
| 安全测试 | TLS 配置 / OAuth2 失败路径 / 敏感字段脱敏 必测 | ✅ 强制 |
| NF 互通测试 | 与至少 1 款第三方 NF 跑互通 | ✅ 强制 |
| 协议一致性套件 | ETSI / Spirent / Keysight 等 | ⏳ 非强制（条件成熟后纳入） |

### 特性接收门

- `spec → plan` 必须通过 Constitution Check
- `plan → implement` 必须通过 Constitution Check
- `implement → main 合入` 必须通过 Constitution Check + 测试门 + 安全门
- Sprint 收官 Checkpoint 必须通过 Constitution Check

## Governance

### 修订流程

- **发起方**：智能体工程师可发起修宪 PR
- **审批方**：架构组 + 安全组（涉安全条款时）
- **格式**：每次修订必须附 ADR，列出 ① 修订动机 ② 影响范围 ③ Sync Impact Report ④ 版本号变化
- **生效**：审批通过后合入 `.specify/memory/constitution.md`，同步更新 `LAST_AMENDED_DATE`

### 版本号语义（SemVer）

- **MAJOR**：删除/重定义某条原则；治理流程不兼容变更
- **MINOR**：新增原则、新增章节、对原则做实质性扩展
- **PATCH**：措辞修订、typo、不改变语义的细化

### 合规审查

- **频率**：每个 Sprint Checkpoint 必跑一次（与测试门同步）
- **工具**：使用 `.harness/` 工具链辅助核验；OpenAPI diff 必跑
- **责任人**：架构组指派 reviewer

### 违规处理

发现违反原则后按下列顺序处理：

1. **修复**（默认路径）：修改代码/文档以符合原则
2. **例外申请**（修复成本过高时）：提 ADR，明确：
   - 违反了哪条原则
   - 为何无法修复
   - 例外有效期与退出条件
   - 由架构组（或安全组）审批；批准后例外记录归档于 `decisions/exceptions/`
3. **回滚**（修复与例外均不可行）：撤回相关代码与功能

MUST NOT 出现"违反但不申报、不修复、不回滚"的灰色状态。

### 优先级

- 本宪法 **凌驾于一切其他项目规章**（包括 CLAUDE.md、各 README、各 ADR）
- 本宪法 **让位于 3GPP / 运营商企业规范**（见 Principle I）
- 本宪法 **让位于法律法规与运营商合同强约束**（隐含上位法规则）
- **安全合规（VI）与协议合规（I）冲突时，以协议为准；但任何协议外的安全增强（更强 TLS / 更短 token 过期）允许做"超额合规"**

### 运行时指导文档

- 运行时智能体行为指导：参见 `CLAUDE.md`（项目根，本期暂未填充时以本宪法为唯一来源）
- 模板与脚本：`.specify/templates/`、`.specify/scripts/`、`.harness/prompts/`、`.harness/scope/`

**Version**: 0.1.0 (Template Draft) | **Drafted**: 2026-05-04 | **Source**: AISware AgileNet-CN NRF Constitution v0.1.0

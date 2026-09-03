#import "template.typ": *

#let purple = rgb("#58318c")
#let pale = rgb("#f3eef9")
#let green = rgb("#26734d")
#let red = rgb("#a43d3d")

#let key(body) = text(fill: purple, weight: "bold", body)
#let good(body) = text(fill: green, weight: "bold", body)
#let bad(body) = text(fill: red, weight: "bold", body)
#let mono(body) = text(font: "DejaVu Sans Mono", size: 0.88em, body)
#let panel(body, fill: pale, stroke: purple) = block(
  width: 100%, inset: 13pt, radius: 5pt,
  fill: fill, stroke: (paint: stroke, thickness: 0.8pt), body)
#let flow-node(body, width: 72%) = box(
  width: width, inset: 9pt, radius: 4pt,
  fill: pale, stroke: (paint: purple, thickness: 0.8pt),
  align(center, body))
#let down = align(center, text(size: 25pt, fill: purple)[↓])
#let src(body) = speaker-note[
  [Sources]
  #body
]

#show: seminar.with(
  title: [PTree：概率事件计算的共归纳语义],
  subtitle: [Stable hitting、coupling 与无界弱互模拟],
  authors: (
    (name: "Linyu Yang", email: ""),
  ),
  date: [2026 年 9 月 3 日],
  outline_: false,
)

== 我们想同时处理三件难事

#set text(size: 22pt)

#grid(
  columns: (1fr, 1fr, 1fr), gutter: 14pt,
  align(center)[#text(size: 30pt, fill: purple)[概率]],
  align(center)[#text(size: 30pt, fill: purple)[交互]],
  align(center)[#text(size: 30pt, fill: purple)[无界计算]],
)

#v(12pt)

- 内部随机选择不是外部事件
- `Vis` 后的 continuation 依赖环境返回值
- 程序可能经过任意多步内部计算，甚至丢失终止质量

#v(8pt)

#panel[
  目标不是“计算最终返回分布”，而是给出一个能同时解释
  #key[概率、可见交互与发散]的行为语义。
]

#src[
- `../README.md`, Introduction and Artifact claims.
- `../theories/Core/PTreeDefinition.v`.
]

== 一个定义必须解释的核心等价

#set text(size: 21pt)

#align(center)[
  #text(size: 27pt)[
    无界重试的偏置硬币抽取器　#key[≈ₚ]　一次公平采样
  ]
]

#v(16pt)

#grid(columns: (1fr, auto, 1fr), gutter: 12pt,
  panel[
    抛两次偏置硬币：

    - 相同：重试
    - 不同：输出第一次结果
  ],
  align(horizon, text(size: 32pt, fill: purple)[≈ₚ]),
  panel[
    直接采样：

    - `false`：$1/2$
    - `true`：$1/2$
  ],
)

#v(12pt)

左边每次运行需要的轮数没有统一上界；等价性必须在 $omega$ 极限上成立。

#src[
- `../theories/Examples/VonNeumannUnbounded.v`.
- `../theories/Examples/OperationalVonNeumann.v`.
]

== 整个语义链只保留一个主行为关系

#set text(size: 20pt)

#align(center)[
  #flow-node[*PTree syntax*　（intensional representation）]
  #down
  #flow-node[*primitive kernel*　$K$]
  #down
  #flow-node[*stable hitting*　$H(t)$]
  #down
  #grid(columns: (1fr, 1fr), gutter: 18pt,
    flow-node(width: 100%)[*关系语义*　$t approx_p u$],
    flow-node(width: 100%)[*定量观察*　$Pr_t["pattern"]$],
  )
]

#v(8pt)

#align(center)[#key[一个行为核心，两个语义客户端。]]

#src[
- `../README.md`, public conceptual architecture.
- `../theories/Eq/ProbabilisticSemantics.v`.
]

== PTree 是带原生概率节点的 interaction tree

#set text(size: 22pt)

#align(center)[
$
  "PTree" ::= "Ret"(r)
    mid "Tau"(t)
    mid "Vis"(e,k)
    mid "Prob"(mu,k)
$
]

#v(18pt)

- `Ret r`：返回结果
- `Tau t`：确定性的内部步
- `Vis e k`：发出外部事件，等待环境给出 $x$，继续 $k(x)$
- `Prob μ k`：内部采样 $x arrow.r.long mu$，继续 $k(x)$

#v(10pt)

#panel[
  `Tau` 和 `Prob` 都是内部计算；#key[只有 `Ret` 与 `Vis` 是稳定观察]。
]

#src[
- `../theories/Core/PTreeDefinition.v`, `ptreeF` and `ptree`.
]

== 语法表示不应决定行为意义

#set text(size: 21pt)

同一个概率行为可以有许多不同的表示：

#align(center)[
$
  mu
  equiv "reorder"(mu)
  equiv "split-mass"(mu)
  equiv "duplicate-and-accumulate"(mu)
$
]

#v(14pt)

程序还可能插入任意多个 `Tau`，或把一次概率选择分解成多次嵌套选择。

#v(10pt)

#panel[
  因而主等价不能按构造器 lockstep 比较；它必须先把内部演化解释成
  #key[外延的 stable behavior]。
]

#src[
- `../README.md`, Enum extensional equality discussion.
- `../theories/Examples/EnumMeasureRegression.v`.
]

== 第一步：把语法降成 primitive kernel

#set text(size: 20pt)

对任意状态空间 $S$，primitive kernel 只产生两类目标：

#align(center)[
$
  K : S arrow "MF"("Stable"(A) + "Internal"(S))
$
]

#v(15pt)

#grid(columns: (1fr, 1fr), gutter: 16pt,
  panel[
    #key[`SHStable out`]

    已经到达可观察的 stable head。
  ],
  panel[
    #key[`SHInternal state`]

    仍需继续执行 primitive kernel。
  ],
)

#v(12pt)

这个定义完全不知道 `Bind`、`Iter` 或某个具体 PTree 证明规则。

#src[
- `../theories/Eq/PrimitiveStableHitting.v`, `stable_target`.
- `../theories/Eq/OperationalProbabilisticPTS.v`, `ptree_primitive_kernel`.
]

== Stable head 保留真正的交互结构

#set text(size: 21pt)

#align(center)[
$
  "Head"(E,R) ::= "FHRet"(r) mid "FHVis"(e,k)
$
]

#v(16pt)

- `FHRet r` 记录返回值
- `FHVis e k` 记录#key[相同的依赖事件]以及整个 continuation
- `Tau` 与 `Prob` 不出现在 stable head 中

#v(10pt)

#definition(title: [关键选择])[
  概率 branching 是内部行为；外部观察者看到的是到达下一个 `Ret/Vis`
  的#key[次概率分布]，而不是内部采样树的形状。
]

#src[
- `../theories/Eq/UnifiedFrontier.v`, `frontier_head`.
- `../README.md`, canonical behavioral semantics.
]

== 有限 approximant：只允许有限次内部推进

#set text(size: 20pt)

定义 $A_n$ 解释一个 stable target：

$
  A_n("Stable"(a)) &= delta_a \
  A_0("Internal"(s)) &= 0 \
  A_(n+1)("Internal"(s)) &= K(s) "bind" A_n
$

#v(12pt)

从状态 $s$ 出发的第 $n$ 个 hitting approximant：

#align(center)[$ H_n(s) = K(s) "bind" A_n $]

#v(12pt)

未在 fuel 内到达 stable head 的质量进入次概率底元 $0$，而已到达的质量立即保留。

#src[
- `../theories/Eq/PrimitiveStableHitting.v`, `stable_target_approx` and `stable_hitting_approx`.
]

== Stable hitting 是同一条链的 ω 极限

#set text(size: 21pt)

#align(center)[
$ H(s) = sup_(n in NN) H_n(s) $
]

#v(14pt)

- $H_n(s) <= H_(n+1)(s)$：看到的稳定质量单调增加
- `stable_hitting s out`：`out` 是这条链的 least upper bound
- `stable_hitting_ast s out`：再要求 $"mass"("out")=1$

#v(12pt)

#panel[
  #key[有限程序与无界 AST 程序没有两套语义。]
  前者只是 approximant chain 提前稳定，后者只在 $omega$ 处收敛。
]

#src[
- `../theories/Eq/PrimitiveStableHitting.v`, stable-hitting limits.
- `../theories/Prob/MeasureIteration.v`.
]

== 发散不是被“弱化”掉，而是成为缺失质量

#set text(size: 22pt)

#grid(columns: (1fr, auto, 1fr), gutter: 14pt,
  panel[
    $1/2$ `Ret true`

    $+$

    $1/2$ `Diverge`

    #bad[stable mass = 1/2]
  ],
  align(horizon, text(size: 34pt)[≉ₚ]),
  panel[
    `Ret true`

    #v(26pt)

    #good[stable mass = 1]
  ],
)

#v(14pt)

coupling 必须保持两边边缘分布，因此也保持缺失质量；不同终止概率不能互模拟。

#src[
- `../theories/Examples/CanonicalPartialDivergence.v`.
- `../theories/Eq/ProbabilisticEutt.v`, mass-mismatch theorem.
]

== “几乎处处”是概率 continuation 的正确粒度

#set text(size: 21pt)

如果某个采样结果的质量为零，我们不应要求它的 continuation 满足证明义务。

#v(10pt)

#align(center)[
$
  "sem_ae"(mu, P)
  quad "而不是" quad
  forall x, P(x)
$
]

#v(14pt)

这使下列性质能穿过无界 hitting 极限：

- Dirac 上 AE 与点性质精确对应
- countable 个 AE 性质可合取
- AE 性质可穿过 Kleisli bind
- coupling 可 transport / restrict 到 AE support

#src[
- `../theories/Prob/TwoLevelMeasure.v`, AE capability classes.
- `../theories/Eq/PrimitiveStableHitting.v`, `stable_hitting_ae`.
- `../theories/Prob/MathCompMeasure.v`, MathComp AE lemmas.
]

== Coupling 把“分布相等”推广为“关系提升”

#set text(size: 21pt)

#align(center)[
$
  mu "  sem_lift"(R) nu
  &arrow.l.r.double exists gamma, \
  &pi_1(gamma)=mu quad "(left marginal)" \
  &pi_2(gamma)=nu quad "(right marginal)" \
  &gamma " is supported by " R
$
]

#v(15pt)

- 当 $R$ 是相等关系时，比较两个分布的同一行为
- 当 $R$ 递归引用程序关系时，coupling 同时配对概率质量与后续状态
- symmetry 来自 coupling converse；transitivity 来自 coupling gluing

#src[
- `../theories/Prob/TwoLevelMeasure.v`, `sem_lift`.
- `../theories/Prob/Coupling.v` and `RelLift.v`.
]

== Stable-head relation 在 Vis 处递归

#set text(size: 20pt)

给定返回值关系 $RR$ 与候选程序关系 $X$：

$
  "HeadRel"(RR,X)("Ret" r_1,"Ret" r_2)
    &arrow.l.r.double RR(r_1,r_2) \
  "HeadRel"(RR,X)("Vis"(e,k_1),"Vis"(e,k_2))
    &arrow.l.r.double forall x, X(k_1(x),k_2(x))
$

#v(13pt)

#panel[
  因而这不是“只比较最终返回分布”的 sampler equivalence：
  它会在每个相同的 dependent event 后继续共归纳比较。
]

#src[
- `../theories/Eq/UnifiedFrontier.v`, `frontier_head_rel`.
- `../README.md`, interactive continuation discussion.
]

== 主关系 = coupling generator 的最大不动点

#set text(size: 20pt)

候选关系 $X$ 的一步 generator：

#align(center)[
$
  Phi(X)(t,u)
  := H(t) "  sem_lift"("HeadRel"(RR,X)) H(u)
$
]

实际定义双向匹配任意 stable-hitting witness；hitting uniqueness 使其等价于上式直觉。

#v(12pt)

#align(center)[
#panel[
  $ t approx_p[RR] u quad := quad (t,u) in nu X. Phi(X) $
]
]

#v(10pt)

generator 中没有 `Tau`、`Prob`、`Bind`、`Iter`、AST 或 frontier constructor。

#src[
- `../theories/Eq/ProbabilisticEutt.v`, `stable_hitting_match`, `stable_hitting_bisim`, and `probabilistic_eutt`.
]

== 它不是把迁移模型照抄成一套规则

#set text(size: 20pt)

#grid(columns: (1fr, 1fr), gutter: 18pt,
  panel[
    #key[语义侧]

    primitive kernel 与 $omega$-hitting 独立定义程序的 stable behavior。
  ],
  panel[
    #key[证明侧]

    `≈ₚ` 只要求这些 behavior 可由递归 head relation coupling。
  ],
)

#v(14pt)

非平凡点在两个方向：

- 内部无界执行必须先证明极限存在、唯一并保留 AE support
- 递归交互必须证明 coupling 与 continuation relation 可共归纳闭合

#v(8pt)

#align(center)[#good[迁移语义定义行为；互模拟证明行为关系。]]

#src[
- `../theories/Eq/PrimitiveStableHitting.v`.
- `../theories/Eq/ProbabilisticEutt.v`.
- `../THEORY_STATUS.md`, canonical architecture.
]

== 等价关系的难点集中在 transitivity

#set text(size: 20pt)

若 $t_1 approx_p t_2$ 且 $t_2 approx_p t_3$：

#v(8pt)

1. 取两组 stable-hitting coupling
2. 用共同的中间边缘分布进行 coupling gluing
3. support 上递归组合 continuation relation
4. 用 hitting uniqueness 消除 witness 选择差异

#v(12pt)

#theorem[
  `probabilistic_eutt` 已注册为 `Equivalence`：reflexive、symmetric、transitive。
]

#v(8pt)

MathComp backend 把 gluing 明确保留为 `MathCompCouplingGluing` capability。

#src[
- `../theories/Eq/ProbabilisticEutt.v`, equivalence proofs.
- `../theories/Prob/TwoLevelMeasureMathComp.v`.
- `../theories/Examples/BackendCapabilities.v`.
]

== 熟悉的程序方程都是 derived laws

#set text(size: 20pt)

$
  "Tau" t &approx_p t \
  "Prob" mu k_1 &approx_p "Prob" nu k_2
    && "if " mu " sem_lift"(R) nu " and continuations agree AE" \
  t_1 "bind" k_1 &approx_p t_2 "bind" k_2
    && "if " t_1 approx_p t_2 " and " k_1 approx_p k_2
$

#v(14pt)

此外还有：

- monad laws、`fmap`、`setoid_rewrite`
- eventful `iter` fusion / naturality / codiagonal
- event translation 与受条件约束的 effectful `interp`

#src[
- `../theories/Eq/ProbabilisticEutt.v`.
- `../theories/Eq/OperationalProbabilisticPTSFreeOmegaRewrite.v`.
- `../theories/Eq/OperationalProbabilisticPTSFreeOmegaIter.v`.
- `../theories/Eq/OperationalProbabilisticPTSFreeOmegaInterp.v`.
]

== 共归纳证明只需展示一个 post-fixed candidate

#set text(size: 20pt)

#align(center)[
$
  X subset.eq Phi(X)
  quad arrow.r.double.long quad
  X subset.eq nu Phi = approx_p
$
]

#v(15pt)

在 Rocq 中由 `coq-coinduction` 提供 greatest-fixed-point proof principle：

#panel[
  对每个 $(t,u) in X$，证明两侧完整 stable-hitting limits 可由
  `HeadRel(RR, X)` coupling，即可推出 $t approx_p u$。
]

#v(10pt)

up-to-`≈ₚ` 与 up-to-bind 进一步减少重复展开，但必须单独证明 closure compatibility，避免循环论证。

#src[
- `../theories/Eq/ProbabilisticEutt.v`, `stable_hitting_bisim_coinduction` and up-to closure.
- `../theories/Eq/OperationalProbabilisticPTSFreeOmega.v`, up-to-bind.
]

== 证明基础设施不是第二套行为语义

#set text(size: 20pt)

#grid(columns: (0.9fr, 2.1fr), gutter: 14pt,
  [#mono[`frontier_certificate`]], [syntax-directed 的 hitting certificate],
  [#mono[`pstructural`]], [证明结构性方程的 lockstep auxiliary relation],
  [#mono[`pstrong`]], [保留概率语法形状的强比较 baseline],
  [#mono[`probabilistic_eutt`]], [#key[唯一 public behavioral equivalence]],
)

#v(17pt)

#panel[
  proof rules 的可靠性表述为：证明关系本身对 native generator 是 post-fixed；
  然后由 greatest-fixed-point principle 进入 `≈ₚ`。
]

#src[
- `../README.md`, proof-infrastructure roles.
- `../theories/Eq/UnifiedFrontier.v`.
- `../theories/Eq/PStrong.v`.
]

== 为什么需要两级测度，而不是一个 M

#set text(size: 20pt)

#align(center)[
  #flow-node[*Node measure*　$M_N$：单个 `Prob` 节点可直接采样]
  #down
  #flow-node[*MixedMeasure*：把 $M_N$ 的一步采样嵌入行为层]
  #down
  #flow-node[*Behavior measure*　$M_F$：承载 $omega$ 极限与 stable hitting]
]

#v(12pt)

- $M_N$ 只需表达原始 sampler
- $M_F = "FreeOmega"(M_N)$ 补足无界行为所需的链极限
- 高级定理依赖 capability classes，而不依赖 Enum 或实数表示

#src[
- `../theories/Prob/TwoLevelMeasure.v`.
- `../theories/Prob/FreeOmegaMeasure.v`.
- `../THEORY_STATUS.md`, backend capability profiles.
]

== Backend：共享维护中的 behavior profile

#set text(size: 17pt)

#table(
  columns: (2.1fr, 1.05fr, 1.25fr),
  inset: 7pt,
  stroke: 0.5pt,
  table.header([*能力*], [*Enum*], [*MathComp*]),
  [node AE / Dirac / countable], [#good[✓]], [#good[✓]],
  [node coupling support / bind-AE exact], [#good[✓]], [#good[✓]],
  [node relational bind], [#good[✓]], [有意不要求],
  [FreeOmega bind / omega / cofinality], [#good[✓]], [#good[✓]],
  [diagonal / Fubini / mixed node-bind], [#good[✓]], [#good[✓]],
  [coupling composition], [直接], [`MathCompCouplingGluing`],
  [commutativity], [optional], [optional],
)

#v(10pt)

#align(center)[#key[追求最终 semantic profile 对称，而不是 node 层形式对称。]]

#src[
- `../theories/Examples/BackendCapabilities.v`.
- `../THEORY_STATUS.md`, Backend capability profiles.
]

== 无界例子：Von Neumann 偏置消除

#set text(size: 21pt)

设源硬币 $Pr[1]=q$，每轮独立抛两次：

#align(center)[
#table(
  columns: (1fr, 1.4fr, 1fr), inset: 8pt, stroke: 0.5pt,
  [*结果*], [*动作*], [*概率*],
  [`00`], [重试], [$(1-q)^2$],
  [`11`], [重试], [$q^2$],
  [`01`], [输出 `0`], [$q(1-q)$],
  [`10`], [输出 `1`], [$q(1-q)$],
)]

#v(12pt)

每轮两个输出质量严格相等；只要 $0<q<1$，重试概率小于 $1$。

#src[
- `../theories/Examples/VonNeumannUnbounded.v`, program and round measure.
]

== q = 2/3 时，收敛只发生在 ω 极限

#set text(size: 20pt)

项目中的 concrete source coin：$Pr["true"]=2/3$。

$
  r &= (1/3)^2 + (2/3)^2 = 5/9 quad "(retry)" \
  s_0 &= s_1 = (1/3)(2/3)=2/9 \
  H_n &= (1-r^n) dot "Fair" \
  lim_(n arrow infinity) H_n &= "Fair", quad "mass"=1
$

#v(14pt)

#panel[
  任意固定 fuel 都会漏掉“需要更多轮”的正质量；AST 与公平性来自
  #key[几何级数的极限证书]，不是有限展开。
]

#src[
- `../theories/Examples/VonNeumannUnbounded.v`, `vn_approx_closed_form`, convergence, and AST certificates.
]

== 终点是行为等价，而非同分布

#set text(size: 21pt)

#align(center)[
$
  "von_neumann_third"
  approx_p
  "direct_fair"
$
]

#v(16pt)

证明分为三层：

1. Enum 上证明 approximant 的闭式与 AST
2. 通过 operational adequacy 得到两边完整 stable-hitting witnesses
3. coupling 两个公平 stable-head measures，再进入 `≈ₚ`

#v(10pt)

#theorem[
  `von_neumann_third_equivalent_to_fair`
]

#src[
- `../theories/Examples/VonNeumannUnbounded.v`.
- `../theories/Examples/OperationalVonNeumann.v`.
]

== 偏置源硬币可以构造目标 q 硬币

#set text(size: 20pt)

#align(center)[
  #flow-node[非退化偏置源硬币　$arrow.r$　Von Neumann 公平 bit stream]
  #down
  #flow-node[binary algorithm：逐位实现目标有理概率 $q$]
  #down
  #flow-node[`direct_q`：一次 Bernoulli($q$) 采样]
]

#v(5pt)

维护中的 concrete theorem：

#align(center)[
$ "third_to_two_fifths" approx_p "direct_two_fifths" $
]

#src[
- `../theories/Examples/BernoulliFactory.v`.
- `../theories/Examples/OperationalBernoulliFactory.v`.
- `../theories/Examples/OperationalRationalBernoulli.v`.
]

== 把 sampler 放回无限交互服务

#set text(size: 20pt)

#align(center)[
$
  "Request" ;
  underbrace("unbounded internal VN", "Tau + Prob") ;
  "Reply"(b) ;
  "repeat forever"
$
]

#v(15pt)

两个 guarded `CoFixpoint` 服务：

- `von_neumann_service`：每次请求后运行无界抽取器
- `direct_fair_service`：每次请求后直接公平采样

#v(10pt)

#theorem[
  `interactive_von_neumann_service_equivalent`：两个无限服务满足 `≈ₚ`。
]

#src[
- `../theories/Examples/InteractiveVonNeumannService.v`, service definitions and equivalence theorem.
]

== 这里的共归纳不是“两边刻意写成一样”

#set text(size: 20pt)

两边确实共享外部协议骨架：`Request ; Reply ; repeat`。

#v(8pt)

但在两次可见事件之间：

#grid(columns: (1fr, 1fr), gutter: 16pt,
  panel[
    #key[VN service]

    两次偏置采样、可能无限重试、$omega$-limit hitting。
  ],
  panel[
    #key[Direct service]

    一次公平 `Prob`，立即到达 reply head。
  ],
)

#v(13pt)

coinductive candidate 只对齐 observable guard；中间完全不同的随机执行由 stable hitting + coupling 消化。

#src[
- `../theories/Examples/InteractiveVonNeumannService.v`.
- `../THEORY_STATUS.md`, interactive case study discussion.
]

== Finite pattern 给出定量行为观察

#set text(size: 20pt)

一个 dependent event selector：

#align(center)[
$ "selector" : forall X, E(X) arrow "option"(X) $
]

它同时：

- 判断事件是否匹配
- 若匹配，给出环境响应 $x$，从而进入 continuation $k(x)$

#v(10pt)

selector list 构成 `finite_interaction_pattern`，表示 finite cylinder，而不必是假设事件可判等的 concrete trace。

#src[
- `../theories/Eq/ProbabilisticTrace.v`, `event_selector` and `finite_interaction_pattern`.
]

== Finite semantics 沿 stable heads 递归

#set text(size: 20pt)

对 pattern $a :: tau$：

1. 求程序的下一 stable-head measure
2. `Ret` 或不匹配的 `Vis` 产生 `false`
3. 匹配 `Vis e k` 时，使用 selector 给出的 $x$ 递归查询 $k(x)$ 与 $tau$
4. 对 branch measure 做 bind，得到 `MF bool`

#v(12pt)

#panel[
  continuation 义务只需对 stable-head measure #key[几乎处处]成立；零质量分支无需伪造证书。
]

#src[
- `../theories/Eq/ProbabilisticTrace.v`, `finite_trace_query`.
]

== `≈ₚ` 对所有有限 cylinder 观察都可靠

#set text(size: 20pt)

#align(center)[
$
  t_1 approx_p[RR] t_2
  quad arrow.r.double.long quad
  "sem_lift"("eq")(
    chevron.l t_1 chevron.r_tau,
    chevron.l t_2 chevron.r_tau)
$
]

#v(15pt)

- 存在性：每一步使用完整 stable hitting
- 唯一性：不同 query witnesses 在 semantic coupling 意义下相同
- `finite_interaction_sem`：用 classical choice 包装一个 representative

#v(10pt)

#definition(title: [准确的 claim])[
  `≈ₚ` is sound for every finite interactive cylinder observation.
]

#src[
- `../theories/Eq/ProbabilisticTrace.v`, existence, uniqueness, and preservation theorems.
- `../README.md`, finite interaction semantics.
]

== 同一个 case study 得到真正的数值结论

#set text(size: 22pt)

选择长度为 2 的 concrete pattern：

#align(center)[
$ tau = ["Request"; "Reply"("true")] $
]

#v(15pt)

#align(center)[
#panel[
  #text(size: 29pt)[
  $ Pr_("von_neumann_service")[tau] = 1/2 $
  ]
]
]

#v(14pt)

这不是把整个无限服务求成 trace distribution；它是由同一个 stable-hitting 核导出的 finite prefix / cylinder probability。

#src[
- `../theories/Examples/InteractiveVonNeumannService.v`, `von_neumann_request_true_reply_trace_probability`.
- `../theories/Eq/ProbabilisticTraceEnum.v`.
]

== 当前理论明确不声称什么

#set text(size: 20pt)

- 不把 `Prob` branching structure 当作外部可观察行为
- 不构造 infinite-trace sigma algebra
- 不提供完整 weakest-preexpectation calculus
- generic interface 下尚不声称 no-`Prob` 时 `≈ₚ ↔ eutt`
- full effectful `interp` preservation 仍由明确的 `Vis` fusion premise 控制

#v(14pt)

#panel[
  这些是#key[刻意的 scope boundary]，而不是在主定义里加入更多 constructor 的理由。
]

#src[
- `../README.md`, Artifact claims and explicit non-claims.
- `../THEORY_STATUS.md`, interp and no-Prob boundaries.
]

== 这项工作的核心贡献

#set text(size: 20pt)

1. 一套同时处理 `Tau`、内部概率、发散和 dependent interaction 的 stable-hitting semantics
2. coupling + greatest fixed point 定义的唯一弱概率等价 `≈ₚ`
3. bounded 与 genuinely unbounded AST 的统一语义和 proof principles
4. Enum 与 MathComp real-measure backend 的 capability-based mechanization
5. 从行为等价到 finite interactive cylinder probability 的定量可靠性

#v(10pt)

#align(center)[#text(size: 25pt, fill: purple, weight: "bold")[
  representation ≠ behavior，proof rules ≠ semantics
]]

#src[
- `../README.md`.
- `../THEORY_STATUS.md`.
]

== 最后留下的一句话

#set text(size: 23pt)

#align(center + horizon)[
#panel[
  #align(center)[
    PTree 用原生概率表示程序，

    stable hitting 提取下一个可见行为，

    coupling 共归纳定义唯一的 `≈ₚ`，

    同一个语义再导出可测的 finite interaction observations。
  ]
]
]

#src[
- `../README.md`, public conceptual architecture.
]

== Appendix：公开 API 的最小词汇

#set text(size: 19pt)

#table(
  columns: (1.5fr, 2.7fr), inset: 8pt, stroke: 0.5pt,
  [#mono[`stable_head`]], [下一个稳定 `Ret/Vis` 观察],
  [#mono[`stable_hitting`]], [$omega$-limit stable behavior],
  [#mono[`probabilistic_eutt`]], [唯一 canonical behavioral equivalence],
  [#mono[`t ≈ₚ u`]], [homogeneous notation，返回关系为 `eq`],
  [#mono[`t ≈ₚ[RR] u`]], [heterogeneous return relation],
  [#mono[`finite_interaction_pattern`]], [dependent-event cylinder pattern],
  [#mono[`finite_interaction_sem`]], [choice-packaged `MF bool` observation],
)

#src[
- `../theories/Eq/ProbabilisticSemantics.v`.
]

== Appendix：关键 theorem 路线图

#set text(size: 17pt)

#grid(columns: (1.2fr, 2.4fr), gutter: 10pt,
  [*Stable hitting*], [existence · uniqueness · increasing · AE preservation],
  [*Equivalence*], [refl · sym · trans · Ret · Tau · Vis · Prob · bind],
  [*Corecursion*], [coinduction · up-to closure · up-to bind],
  [*Iteration*], [unfold · fusion · naturality · codiagonal],
  [*Interaction*], [translate · guarded Vis matching · interp under fusion],
  [*Quantitative*], [finite query existence · uniqueness · `≈ₚ` preservation],
  [*Examples*], [biased→fair · rational $q$ · interactive service · $Pr=1/2$],
)

#src[
- `../THEORY_STATUS.md`, maintained theorem inventory.
]

== Appendix：论文阶段的四个问题

#set text(size: 20pt)

最值得写清楚的四个问题：

- stable hitting 如何压缩成清晰的 mathematical definition
- novelty 相对 weak probabilistic bisimulation 如何定位
- two-level measures 为什么是语义需求而非 Rocq 偶然
- Von Neumann service 如何同时展示 unboundedness、interaction、equivalence 与 probability

#v(16pt)

#align(center)[#key[核心定义已经定型；剩余工作主要是 characterization 与 presentation。]]

#src[
- `../README.md`.
- `../THEORY_STATUS.md`.
]

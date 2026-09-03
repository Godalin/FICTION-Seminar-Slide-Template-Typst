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
  title: [PTree：概率交互的余归纳语义],
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

#set text(size: 20pt)

#align(center)[
$
  "ptreeF"(E,M,R,T) ::= "RetF"(r) | "TauF"(t)
    | "VisF"(e,k) | "ProbF"(mu,k)
$
]

#v(8pt)

#panel[
  #mono[`CoInductive ptree := go { _observe : ptreeF ptree }.`]

  一次 `observe` 只展开一层；`TauF`、`VisF` 和 `ProbF` 的后继仍是
  `ptree`，所以程序可无限展开。
]

#v(8pt)

- `Ret r`：返回结果
- `Tau t`：确定性的内部步
- `Vis e k`：发出外部事件，等待环境给出 $x$，继续 $k(x)$
- `Prob μ k`：内部采样 $x arrow.r.long mu$，继续 $k(x)$

#v(5pt)

#panel[
  `Tau` 和 `Prob` 都是内部计算；#key[只有 `Ret` 与 `Vis` 是稳定观察]。
]

#src[
- `../theories/Core/PTreeDefinition.v`, `ptreeF` and `ptree`.
]

== 概率参数不是固定的枚举分布

#set text(size: 18pt)

源码中的 `M : Type → Type` 只出现在 `ProbF`：

#align(center)[
$ "ProbF" : forall X, M(X) arrow (X arrow "ptree") arrow "ptreeF" $
]

#v(8pt)

语义层通过 `SemanticMeasure M` 只要求五个操作：

#panel[
  #mono[`sem_ret`]：Dirac measure　　#mono[`sem_bind`]：Kleisli composition

  #mono[`sem_eq`]：语义相等　　　　#mono[`sem_ae`]：几乎处处性质

  #mono[`sem_lift R μ ν`]：用关系 `R` coupling 两个 measure
]

#v(8pt)

具体代数定律不塞进结构本身，而由 `SemanticMeasureCoreLaws`、
`SemanticMeasureBindLaws`、AE/omega capability classes 分别提供。

#src[
- `../theories/Prob/TwoLevelMeasure.v`, `SemanticMeasure` and law classes.
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

#set text(size: 18pt)

generic 层只规定目标类型：

#align(center)[
$
  "stable_target"(S,A) ::= "SHStable"(a) | "SHInternal"(s)
$
]

#v(5pt)

PTree 将一次 `observe` 实例化为下面四个 kernel 方程：

#panel[
$
 K("RetF" r) &= delta_("Stable"("FHRet" r)) \
 K("VisF" e k) &= delta_("Stable"("FHVis" e k)) \
 K("TauF" t) &= delta_("Internal"("observe" t)) \
 K("ProbF" mu k) &= "mixed_bind"(mu, x mapsto
   delta_("Internal"("observe"(k(x)))))
$
]

#v(5pt)

前三个方程是 Dirac；`ProbF` 才调用 node measure $M_N$ 与 behavior
measure $M_F$ 之间的 `mixed_bind`。kernel 不识别 `Bind` 或 `Iter`。

#src[
- `../theories/Eq/PrimitiveStableHitting.v`, `stable_target`.
- `../theories/Eq/OperationalProbabilisticPTS.v`, `ptree_primitive_kernel`.
]

== Stable head 保留真正的交互结构

#set text(size: 21pt)

#align(center)[
$
  "Head"(E,R) ::= "FHRet"(r) | "FHVis"(e,k)
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

== Stable hitting 的接口不是“取一个随意极限”

#set text(size: 18pt)

项目定义直接使用 backend 的 least-upper-bound judgment：

#panel[
$
 "stable_hitting"(K,s,"out")
  &:= "sem_lub"((n mapsto H_n(s)), "out") \
 "stable_hitting_ast"(K,s,"out")
  &:= "stable_hitting"(K,s,"out") and "sem_total"("out")
$
]

#v(8pt)

在 `SemanticMeasureOrderLaws + SemanticOmegaLaws` 下证明：

#theorem(title: [Existence / uniqueness])[
  `stable_hitting_exists`：$forall s, exists "out", H(s)="out"$。

  `stable_hitting_unique`：若 $H(s)="out"_1$ 且 $H(s)="out"_2$，
  则 $"sem_eq"("out"_1,"out"_2)$。
]

#v(6pt)

因此后续互模拟可以量化任意 hitting witness；证明结果不依赖某个
chosen representative。

#src[
- `../theories/Eq/PrimitiveStableHitting.v`, `stable_hitting`, existence and uniqueness.
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
  它会在每个相同的 dependent event 后继续余归纳地比较。
]

#src[
- `../theories/Eq/UnifiedFrontier.v`, `frontier_head_rel`.
- `../README.md`, interactive continuation discussion.
]

== 主关系 = coupling generator 的最大不动点

#set text(size: 18pt)

先定义候选关系 $X$ 对一对状态的完整行为匹配：

#panel[
$
 "match"_X(s_1,s_2) :=
 &(forall o_1, H_1(s_1,o_1) arrow
   exists o_2, H_2(s_2,o_2) and o_1 overline("AR"(X)) o_2) \
 &and (forall o_2, H_2(s_2,o_2) arrow
   exists o_1, H_1(s_1,o_1) and o_1 overline("AR"(X)) o_2)
$
]

#v(7pt)

其中 $H_i(s,o)$ 就是 `stable_hitting kernelᵢ s o`，横线上标表示
`sem_lift`。两个方向都写入定义，因此它直接支持 heterogeneous kernels。

#v(7pt)

#align(center)[
#panel[
  $ "stable_hitting_bisim" := nu X. "match"_X $
]
]

#v(5pt)

`AR` 只需对 $X$ 单调；generator 中没有 `Tau`、`Prob`、`Bind`、
`Iter`、AST 或 frontier constructor。

#src[
- `../theories/Eq/ProbabilisticEutt.v`, `stable_hitting_match`, `stable_hitting_bisim`, and `probabilistic_eutt`.
]

== `probabilistic_eutt` 只是 generic gfp 的 PTree 实例

#set text(size: 18pt)

PTree 状态是 `ptree'`，observable relation 取：

#panel[
$
 "ptree_stable_head_rel"(X)
 := "frontier_head_rel"(RR,
   (t_1,t_2) mapsto X("observe" t_1,"observe" t_2))
$
]

#v(7pt)

然后把 $K$、stable head 与上述 relation 代入 generic 定义：

#panel[
$
 "probabilistic_eutt_state" &:=
   "stable_hitting_bisim"(K,K,"ptree_stable_head_rel") \
 "probabilistic_eutt"(RR,t_1,t_2) &:=
   "probabilistic_eutt_state"("observe" t_1,"observe" t_2)
$
]

#v(6pt)

记号 `t₁ ≈ₚ[RR] t₂` 展开为第二行；`t₁ ≈ₚ t₂` 再令 `RR = eq`。

#src[
- `../theories/Eq/ProbabilisticEutt.v`, `ptree_stable_head_rel`, `probabilistic_eutt_state`, and `probabilistic_eutt`.
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
- 递归交互必须证明 coupling 与 continuation relation 可在余归纳下闭合

#v(8pt)

#align(center)[#good[迁移语义定义行为；互模拟证明行为关系。]]

#src[
- `../theories/Eq/PrimitiveStableHitting.v`.
- `../theories/Eq/ProbabilisticEutt.v`.
- `../THEORY_STATUS.md`, canonical architecture.
]

== 等价关系的难点集中在 transitivity

#set text(size: 18pt)

#theorem(title: [`probabilistic_eutt_trans`])[
$
 forall t_1 t_2 t_3,
 (t_1 approx_p t_2) arrow (t_2 approx_p t_3) arrow (t_1 approx_p t_3).
$
]

#v(6pt)

证明展开一次 gfp 后做四件事：

1. 为 $t_1,t_2$ 与 $t_2,t_3$ 取两组完整 hitting couplings
2. 用 hitting uniqueness 把两个 $t_2$ witness 对齐
3. 对共同中间边缘执行 coupling gluing
4. 对 support 上的 `FHRet/FHVis` relation 递归做关系组合

#v(5pt)

最终实例：

#mono[`Global Instance probabilistic_eutt_equivalence : Equivalence probabilistic_eutt.`]

#v(4pt)

MathComp backend 把第 3 步明确暴露为 `MathCompCouplingGluing` capability。

#src[
- `../theories/Eq/ProbabilisticEutt.v`, equivalence proofs.
- `../theories/Prob/TwoLevelMeasureMathComp.v`.
- `../theories/Examples/BackendCapabilities.v`.
]

== 熟悉的程序方程都是 derived laws

#set text(size: 18pt)

#theorem(title: [Silent / return / visible laws])[
$
 "probabilistic_eutt_tau_l":& quad "Tau"(t) approx_p t \
 "probabilistic_eutt_ret":& quad RR(r_1,r_2) arrow
   "Ret"(r_1) approx_p[RR] "Ret"(r_2) \
 "probabilistic_eutt_vis":& quad
   (forall x, k_1(x) approx_p[RR] k_2(x)) arrow
   "Vis"(e,k_1) approx_p[RR] "Vis"(e,k_2)
$
]

#v(7pt)

#theorem(title: [Sampling congruence])[
$
 mu_1 overline("XR") mu_2 quad and quad
 (forall x_1 x_2, "XR"(x_1,x_2) arrow k_1(x_1) approx_p k_2(x_2))
 \
 arrow "Prob"(mu_1,k_1) approx_p "Prob"(mu_2,k_2).
$
]

#v(5pt)

这些都是先证明相应完整 hitting measures 可 coupling，再用 `fold` 进入 gfp；
它们不是互模拟定义的 constructor。

#src[
- `../theories/Eq/ProbabilisticEutt.v`, Tau, Ret, Vis, and Prob congruence theorems.
]

== Bind congruence 展开了返回后的行为

#set text(size: 18pt)

#theorem(title: [`probabilistic_eutt_bind`])[
$
 &t_1 approx_p[RR] t_2 \
 &and (forall r_1 r_2, RR(r_1,r_2) arrow k_1(r_1) approx_p k_2(r_2)) \
 &arrow "bind"(t_1,k_1) approx_p "bind"(t_2,k_2).
$
]

#v(8pt)

关键证明对象 `bind_bisim_candidate` 包含两种状态：

- 已经属于 `probabilistic_eutt_state` 的 pair
- 一对相关 source 分别 bind 一对逐点相关 continuation 后的 pair

#v(6pt)

`stable_hitting_weak_bind` 用 global/diagonal fuel cofinality 把 source hitting
与 continuation hitting 组合；随后 `sem_lift_bind` 组合 couplings。

#src[
- `../theories/Eq/ProbabilisticEutt.v`.
- `../theories/Eq/OperationalProbabilisticPTSFreeOmegaRewrite.v`.
- `../theories/Eq/OperationalProbabilisticPTSFreeOmegaIter.v`.
- `../theories/Eq/OperationalProbabilisticPTSFreeOmegaInterp.v`.
]

== 余归纳证明只需展示一个 post-fixed candidate

#set text(size: 18pt)

#theorem(title: [`probabilistic_eutt_coinduction`])[
给定候选关系 `sim`。若
$
 forall s_1 s_2,
 "sim"(s_1,s_2) arrow "stable_hitting_match"("sim",s_1,s_2),
$
则对任意 trees：
$
 "sim"("observe" t_1,"observe" t_2) arrow t_1 approx_p[RR] t_2.
$
]

#v(7pt)

这正是 $X subset.eq Phi(X) arrow X subset.eq nu Phi$ 的 Rocq 版本；
`coq-coinduction` 只提供 greatest-fixed-point principle，不改变 generator。

#v(7pt)

up-to theorem 把 conclusion 中的 `sim` 换成 `clo sim`，但额外要求：

- `sim ⊆ clo sim`
- 若 `sim` progress 到 `clo sim`，则整个 `clo sim` 也 progress

这条 compatibility premise 阻止用尚未证明的 bind congruence 循环证明自身。

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

#set text(size: 18pt)

#align(center)[
  #flow-node[*Node measure*　$M_N$：单个 `Prob` 节点可直接采样]
  #down
  #flow-node[*MixedMeasure*：把 $M_N$ 的一步采样嵌入行为层]
  #down
  #flow-node[*Behavior measure*　$M_F$：承载 $omega$ 极限与 stable hitting]
]

#v(5pt)

#panel[
`MixedMeasure MN MF` 只有一个操作：

$ "mixed_bind" : M_N(A) arrow (A arrow M_F(B)) arrow M_F(B). $
]

#v(5pt)

- $M_N$ 只需表达 `Prob μ k` 中存储的原始 sampler
- $M_F = "FreeOmega"(M_N)$ 承载 `sem_zero`、`sem_lub` 与 hitting limit

#src[
- `../theories/Prob/TwoLevelMeasure.v`.
- `../theories/Prob/FreeOmegaMeasure.v`.
- `../THEORY_STATUS.md`, backend capability profiles.
]

== `mixed_lift_bind` 是两级语义的关系桥梁

#set text(size: 18pt)

#theorem(title: [`MixedMeasureLaws.mixed_lift_bind`])[
若
$
 mu_1 overline(R) mu_2
 quad "且" quad
 forall x y, R(x,y) arrow f_1(x) overline(T) f_2(y),
$
则
$
 "mixed_bind"(mu_1,f_1) overline(T)
 "mixed_bind"(mu_2,f_2).
$
]

#v(8pt)

它在 `probabilistic_eutt_prob` 中正好连接两层：

1. node 层 coupling 配对 `Prob` 的采样值
2. 每对相关值的 continuation 先得到 behavior-level hitting coupling
3. `mixed_lift_bind` 合成为整个 `Prob` 节点的 behavior coupling

#v(7pt)

这解释了为什么只用一个普通 monad interface 不够：关系证明必须跨越
$M_N$ 与 $M_F$。

#src[
- `../theories/Prob/TwoLevelMeasure.v`, `MixedMeasureLaws`.
- `../theories/Eq/ProbabilisticEutt.v`, `probabilistic_eutt_prob`.
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

#set text(size: 18pt)

#theorem(title: [`probabilistic_eutt_von_neumann_raw_direct`])[
$
 @"probabilistic_eutt"("vnE", "Enum", "FreeOmega Enum", "eq",
   "von_neumann_third", "direct_fair").
$

省略的 typeclass 参数由 Enum node measure、FreeOmega behavior measure
及其 core/omega/mixed instances填充。
]

#v(7pt)

证明分为三层：

1. `von_neumann_third_almost_surely_terminates`：迭代极限总质量为 $1$
2. `operational_von_neumann_raw_ast`：构造左侧完整 stable-hitting witness
3. `operational_vn_direct_ast`：构造右侧一步公平 witness
4. `operational_vn_raw_heads_lift`：以 `eq` coupling 两个 head measures
5. `probabilistic_eutt_of_hitting_lift`：由上述三项进入 gfp

#v(5pt)

结论比“两个返回分布相同”更强：它是 canonical behavioral relation
中的 theorem，可直接被 bind、iter 与交互上下文复用。

#src[
- `../theories/Examples/VonNeumannUnbounded.v`.
- `../theories/Examples/OperationalVonNeumann.v`.
]

== 偏置源硬币可以构造目标 q 硬币

#set text(size: 18pt)

#align(center)[
  #flow-node[非退化偏置源硬币　$arrow.r$　Von Neumann 公平 bit stream]
  #down
  #flow-node[binary algorithm：逐位实现目标有理概率 $q$]
  #down
  #flow-node[`direct_q`：一次 Bernoulli($q$) 采样]
]

#v(4pt)

generic theorem 的前提是：源概率归一化且非退化，目标有理数满足
$0 <= q <= 1$；此外 backend 提供 step/rational support laws。

#src[
- `../theories/Examples/BernoulliFactory.v`, generic construction.
]

== Concrete factory theorem 比较完整程序行为

#set text(size: 18pt)

#theorem(title: [`probabilistic_eutt_third_to_two_fifths_direct`])[
在 `OperationalFactoryStepSupportLaws(1/3,2/3)` 与
`OperationalFactoryRationalSupportLaws(2/5)` 下：

$ "third_to_two_fifths" approx_p "direct_two_fifths". $
]

#v(4pt)

左侧定义为 `PTree.iter factory_binary_step (2/5)`；每一步所需公平 bit
由前面的无界 Von Neumann extractor 产生。右侧仅含一次
`Prob (Bernoulli 2/5)`。

#src[
- `../theories/Examples/BernoulliFactory.v`.
- `../theories/Examples/OperationalBernoulliFactory.v`.
- `../theories/Examples/OperationalRationalBernoulli.v`.
]

== 把 sampler 放回无限交互服务

#set text(size: 17pt)

#panel[
#mono[`serve_round sampler next :=`]

#mono[`  Vis CoinRequest (fun _ =>`]

#mono[`    bind sampler (fun b => Vis (CoinReply b) (fun _ => next))).`]
]

#v(6pt)

两个 guarded `CoFixpoint` 只替换 `sampler`：

- `von_neumann_service`：每次请求后运行无界抽取器
- `direct_fair_service`：每次请求后直接公平采样

#v(6pt)

#theorem(title: [`interactive_von_neumann_service_equivalent`])[
  $ "von_neumann_service" approx_p "direct_fair_service". $

  实例参数：$E="coin_serviceE"$，$M_N="Enum"$，
  $M_F="FreeOmega Enum"$，$RR="eq"$。
]

#v(4pt)

证明使用 `probabilistic_eutt_coinduction_upto`；候选关系含 root pair 与
两侧处理完 `CoinRequest` 后的 pair。

#src[
- `../theories/Examples/InteractiveVonNeumannService.v`, service definitions and equivalence theorem.
]

== 这里的余归纳不是“两边刻意写成一样”

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

余归纳候选关系只对齐 observable guard；中间完全不同的随机执行由
stable hitting + coupling 消化。

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

#set text(size: 17pt)

`finite_trace_query pattern t query : Prop` 是真正的递归定义：

#panel[
- 空 pattern：$"sem_eq"("query", delta_"true")$

- `select :: rest`：存在 `out` 与 `branch`，满足

$ H(t,"out") $

$ "sem_ae"("out", h mapsto P(h)) $，其中

$ P("FHRet" r) := "branch"("FHRet" r) equiv delta_"false" $

$ P("FHVis"(e,k)) := "query"("rest",k(x),"branch"("FHVis"(e,k))) $
若 `select e = Some x`；否则要求 $"branch"("FHVis"(e,k)) equiv delta_"false"$。

$ "sem_eq"("sem_bind"("out","branch"), "query"). $
]

#v(5pt)

continuation 义务只对 `out` #key[几乎处处]成立；零质量 head 无需构造
递归 query。这也是 definition 使用 `Prop` witness 而非直接递归函数的原因。

#src[
- `../theories/Eq/ProbabilisticTrace.v`, `finite_trace_query`.
]

== `≈ₚ` 对所有有限 cylinder 观察都可靠

#set text(size: 17pt)

#theorem(title: [`finite_trace_query_exists`])[
$ forall tau,t. exists q, "finite_trace_query"(tau,t,q). $
]

#v(4pt)

#theorem(title: [`finite_trace_query_unique_up_to_coupling`])[
$ "query"(tau,t,q_1) and "query"(tau,t,q_2)
  arrow q_1 overline("eq") q_2. $
]

#v(4pt)

#theorem(title: [`probabilistic_eutt_preserves_finite_interaction_sem`])[
$
 t_1 approx_p[RR] t_2 arrow
 "finite_interaction_sem"(tau,t_1)
   overline("eq")
 "finite_interaction_sem"(tau,t_2).
$
]

#v(4pt)

`finite_interaction_sem τ t` 用 classical `epsilon` 选择一个满足 query 的
representative。generic 层只声明它们可由 `eq` coupling；只有具备
equality reflection 的 concrete backend 才进一步得到表示相等。

#src[
- `../theories/Eq/ProbabilisticTrace.v`, existence, uniqueness, and preservation theorems.
- `../README.md`, finite interaction semantics.
]

== 同一个 case study 得到真正的数值结论

#set text(size: 18pt)

选择长度为 2 的 concrete pattern：

#align(center)[
$ tau = ["Request"; "Reply"("true")] $
]

#v(7pt)

#theorem(title: [`von_neumann_request_true_reply_trace_probability`])[
#align(center)[
  #text(size: 25pt)[$ Pr_t["von_neumann_service" | tau] = 1/2 $]
]
]

#v(7pt)

concrete Enum API 展开这个记号时要求存在：

1. 一个 `finite_trace_query τ t query` witness
2. 一个与 `query` 由 `eq` coupling 的 FreeOmega representative
3. representative denotation 到某个 Enum distribution `out`
4. `enum_expect bool_indicator out = 1/2`

#v(5pt)

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

    coupling 余归纳地定义唯一的 `≈ₚ`，

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
  [*余归纳*], [基本余归纳 · up-to closure · up-to bind],
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

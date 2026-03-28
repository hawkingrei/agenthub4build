---
theme: seriph
title: 从 Agent Team 到 AI Fuzzing
info: |
  一个关于 AgentHub team runtime、TiDB skills、memory 设计与 Shiro 的 Slidev deck。
class: text-left
lineNumbers: false
transition: slide-left
drawings:
  persist: false
mdc: true
colorSchema: light
routerMode: hash
---

<div class="slide-shell">
  <div class="aurora"></div>
  <div class="eyebrow">工程系统视角</div>
  <div class="max-w-5xl mt-8">
    <h1 class="!text-6xl !leading-tight !mb-6">从 Agent Team 到 AI Fuzzing</h1>
    <p class="text-2xl leading-10 max-w-4xl">
      以 AgentHub 作为协作底座，以 TiDB skills 作为领域能力，以 memory 作为长周期连续性，
      以 Shiro 作为优化器 bug 的发现引擎。
    </p>
  </div>

  <div class="grid grid-cols-2 gap-4 max-w-4xl mt-12">
    <div class="panel p-5">
      <div class="eyebrow">范围</div>
      <div class="mt-2 text-lg font-semibold">Agent team、actor protocol、workflow、memory、TiDB skills、Shiro</div>
    </div>
    <div class="panel p-5">
      <div class="eyebrow">核心判断</div>
      <div class="mt-2 text-lg font-semibold">真正有用的 AI 系统，来自协作、专长、持久状态和领域闭环的组合</div>
    </div>
  </div>

  <div class="flex flex-wrap gap-3 mt-10">
    <span class="tag">AgentHub Team Runtime</span>
    <span class="tag">Actor Mailbox</span>
    <span class="tag">TiDB Skill Pack</span>
    <span class="tag">Filesystem Memory</span>
    <span class="tag">Shiro Guided Fuzzing</span>
  </div>
</div>

---

<div class="slide-shell soft-grid">
  <div class="aurora" style="opacity: 0.55"></div>
  <div class="eyebrow">总览</div>
  <h1 class="!mt-3 !mb-8">这套栈是四个系统，不是一个单点产品</h1>

  <div class="grid grid-cols-2 gap-5">
    <div class="panel p-6">
      <div class="metric">01</div>
      <div class="mini-title mt-3">协作</div>
      <p class="mt-2 muted">
        多个 agent 如何共享工作，而不是把一次 run 变成不可回放的聊天。
      </p>
    </div>
    <div class="panel p-6">
      <div class="metric">02</div>
      <div class="mini-title mt-3">专长</div>
      <p class="mt-2 muted">
        可复用的 skills 如何让 prompt 保持紧凑，同时让领域行为更精确。
      </p>
    </div>
    <div class="panel p-6">
      <div class="metric">03</div>
      <div class="mini-title mt-3">连续性</div>
      <p class="mt-2 muted">
        memory 如何把易变的 runtime 状态和持久的项目知识分开。
      </p>
    </div>
    <div class="panel p-6">
      <div class="metric">04</div>
      <div class="mini-title mt-3">领域闭环</div>
      <p class="mt-2 muted">
        Shiro 如何把优化器测试变成一个可引导、可回放、可分诊的系统。
      </p>
    </div>
  </div>

  <div class="panel panel-strong p-6 mt-6">
    <div class="quote-line">
      <div class="mini-title">关键视角</div>
      <p class="mt-2">
        单 agent demo 优化的是一次回答；生产级工程系统优化的是委派、回放、证据和恢复。
      </p>
    </div>
  </div>
</div>

---

<div class="slide-shell">
  <div class="aurora" style="opacity: 0.62"></div>
  <div class="eyebrow">为什么需要 Team</div>
  <h1 class="!mt-3 !mb-6">AgentHub 不是一个更聪明的 agent，而是一套有纪律的 Team</h1>

  <div class="grid grid-cols-2 gap-6">
    <div class="panel p-6">
      <div class="mini-title">没有 Team model 时</div>
      <ul class="mt-3 compact-list">
        <li>一个 prompt 必须同时承载 planning、execution、review 和 reporting。</li>
        <li>context 很快会被日志、半成品决策和重复状态更新塞满。</li>
        <li>人的协作意图和执行控制会被混在一起。</li>
        <li>失败后的恢复很难，因为 ownership 是隐式的。</li>
      </ul>
    </div>
    <div class="panel p-6">
      <div class="mini-title">有 AgentHub model 时</div>
      <ul class="mt-3 compact-list">
        <li>Leader 负责 planning、decomposition、review 和 synthesis。</li>
        <li>Workers 负责 execution、evidence 生产和本地记录。</li>
        <li>Conversation 保持对人友好，Task 和 Run 保持对机器可审计。</li>
        <li>Mailbox evidence 成为跨 agent 协作的持久记录。</li>
      </ul>
    </div>
  </div>

  <div class="panel p-6 mt-6">
    <div class="mini-title">Canonical Team model</div>
    <div class="grid grid-cols-3 gap-4 mt-4">
      <div>
        <div class="eyebrow">第 1 层</div>
        <div class="font-semibold mt-1">Conversation</div>
        <p class="muted mt-2">面向人的通道，用来承载目标、约束、确认和提问。</p>
      </div>
      <div>
        <div class="eyebrow">第 2 层</div>
        <div class="font-semibold mt-1">Task Ownership</div>
        <p class="muted mt-2">Leader 把达成一致的工作转成 canonical task，并明确 ownership。</p>
      </div>
      <div>
        <div class="eyebrow">第 3 层</div>
        <div class="font-semibold mt-1">Execution Telemetry</div>
        <p class="muted mt-2">Run 和 step 是调试工件，不是主要协作单位。</p>
      </div>
    </div>
  </div>
</div>

---

<div class="slide-shell">
  <div class="aurora" style="opacity: 0.56"></div>
  <div class="eyebrow">架构</div>
  <h1 class="!mt-3 !mb-6">Actor 是协作底座</h1>

  <div class="grid grid-cols-4 gap-4">
    <div class="panel p-4">
      <div class="mini-title">Conversation</div>
      <p class="muted mt-2">人的目标和反馈停留在共享通道中。</p>
    </div>
    <div class="panel p-4">
      <div class="mini-title">Task / Run</div>
      <p class="muted mt-2">Leader 把意图转换成明确的工作对象。</p>
    </div>
    <div class="panel p-4">
      <div class="mini-title">Actor Mailbox</div>
      <p class="muted mt-2">跨 agent 交付始终遵循 <code>send -> inbox -> ack</code>。</p>
    </div>
    <div class="panel p-4">
      <div class="mini-title">Workers</div>
      <p class="muted mt-2">execution 和 evidence 通过角色化 agent 流动。</p>
    </div>
  </div>

  <div class="grid grid-cols-7 gap-3 mt-5 text-sm">
    <div class="flow-pill">Human</div>
    <div class="flow-pill">Leader</div>
    <div class="flow-pill">Task</div>
    <div class="flow-pill">Run</div>
    <div class="flow-pill">Mailbox</div>
    <div class="flow-pill">Worker</div>
    <div class="flow-pill">Review</div>
  </div>

  <div class="grid grid-cols-3 gap-4 mt-5">
    <div class="panel p-4">
      <div class="mini-title">Skills</div>
      <p class="muted mt-2">Role、phase 和 domain skills 共同塑造行为，而不是依赖一个不断膨胀的大 prompt。</p>
    </div>
    <div class="panel p-4">
      <div class="mini-title">Memory</div>
      <p class="muted mt-2"><code>.cache/context</code> 保存 runtime continuity；<code>.agenthubmemory</code> 保存 durable notes。</p>
    </div>
    <div class="panel p-4">
      <div class="mini-title">Event bus</div>
      <p class="muted mt-2">实时可见性和 authoritative mailbox completion 是分开的。</p>
    </div>
  </div>

  <div class="grid grid-cols-3 gap-4 mt-5">
    <div class="panel p-4">
      <div class="mini-title">Identity</div>
      <p class="muted mt-2"><code>actor_id</code> 是 canonical identity；<code>run_id</code> 用来切分 replay 和 delivery。</p>
    </div>
    <div class="panel p-4">
      <div class="mini-title">Reliability</div>
      <p class="muted mt-2">采用 at-least-once delivery，并要求 send 和 ack 具备 idempotent 语义。</p>
    </div>
    <div class="panel p-4">
      <div class="mini-title">Authority</div>
      <p class="muted mt-2">Main DB 是真相来源；event bus 负责实时 fan-out，而不负责 execution truth。</p>
    </div>
  </div>
</div>

---

<div class="slide-shell">
  <div class="aurora" style="opacity: 0.58"></div>
  <div class="eyebrow">协议</div>
  <h1 class="!mt-3 !mb-6">Actor loop 被刻意收得很小</h1>

  <div class="grid grid-cols-[1.15fr_0.85fr] gap-6">
    <div class="panel code-card p-5">
      <div class="mini-title mb-3">Mailbox-first 协作</div>
      <div class="rounded-4 bg-stone-950 text-amber-50 font-mono text-sm leading-6 p-4 whitespace-pre">agenthub actor inbox --limit 50
agenthub actor ack --message-id [message_id]
agenthub actor send --to-actor-id [member_id] --text-file update.md
agenthub actor send --channel-id all --text-file broadcast.md</div>
      <p class="muted mt-4">
        这个 contract 被有意收窄：读取工作、确认 evidence、发送下一状态。
      </p>
    </div>

    <div class="panel p-5">
      <div class="mini-title">为什么重要</div>
      <ul class="mt-3 compact-list">
        <li>稳定的 surface 意味着更小的 prompt 和更少的隐藏执行路径。</li>
        <li><code>run_id</code> 让 replay 保持 deterministic。</li>
        <li><code>pending_count</code> 提供一个低成本的未读快照。</li>
        <li>channel event 改善 UX，但 mailbox ack 仍然是完成信号。</li>
      </ul>
    </div>
  </div>

  <div class="grid grid-cols-5 gap-3 mt-6 text-sm">
    <div class="flow-pill">1. inbox</div>
    <div class="flow-pill">2. parse</div>
    <div class="flow-pill">3. act</div>
    <div class="flow-pill">4. ack</div>
    <div class="flow-pill">5. report</div>
  </div>
</div>

---

<div class="slide-shell">
  <div class="aurora" style="opacity: 0.62"></div>
  <div class="eyebrow">工作流</div>
  <h1 class="!mt-3 !mb-8">六个 phase 让 Team run 保持可理解</h1>

  <div class="grid grid-cols-3 gap-4">
    <div class="panel p-5">
      <div class="metric">1</div>
      <div class="mini-title mt-3">Team formation</div>
      <p class="muted mt-2">确认 roster、能力缺口和运行假设。</p>
    </div>
    <div class="panel p-5">
      <div class="metric">2</div>
      <div class="mini-title mt-3">Task analysis</div>
      <p class="muted mt-2">拆解目标、约束、风险和 acceptance criteria。</p>
    </div>
    <div class="panel p-5">
      <div class="metric">3</div>
      <div class="mini-title mt-3">Role assignment</div>
      <p class="muted mt-2">把具体工作绑定给最适合该任务的 worker card。</p>
    </div>
    <div class="panel p-5">
      <div class="metric">4</div>
      <div class="mini-title mt-3">Communication</div>
      <p class="muted mt-2">推进 checkpoint、解除阻塞，并保持 evidence 新鲜。</p>
    </div>
    <div class="panel p-5">
      <div class="metric">5</div>
      <div class="mini-title mt-3">Consensus</div>
      <p class="muted mt-2">比较 evidence、解决分歧、锁定决策。</p>
    </div>
    <div class="panel p-5">
      <div class="metric">6</div>
      <div class="mini-title mt-3">Integration</div>
      <p class="muted mt-2">把输出汇总成一个面向人的答案，并完成闭环。</p>
    </div>
  </div>

  <div class="panel panel-strong p-5 mt-6">
    <div class="mini-title">关键设计选择</div>
    <p class="mt-2">
      Conversation 不是 canonical task ledger。canonical execution unit 是 Task，
      canonical delivery evidence 是围绕该 Task 的 mailbox 交换。
    </p>
  </div>
</div>

---

<div class="slide-shell">
  <div class="aurora" style="opacity: 0.6"></div>
  <div class="eyebrow">Memory</div>
  <h1 class="!mt-3 !mb-6">Memory management 按生命周期拆分，而不是按方便程度拆分</h1>

  <div class="grid grid-cols-2 gap-6">
    <div class="panel p-6">
      <div class="mini-title">Runtime continuity</div>
      <p class="muted mt-2">易失、run-scoped，并针对恢复和压缩优化。</p>
      <ul class="mt-4 compact-list">
        <li>主路径：<code>.cache/context/run/[run_id]/...</code></li>
        <li>超大日志、stack trace 和 artifacts 通过 pointer 存储。</li>
        <li>保持 prompt prefix 稳定，把易变部分放进 dynamic tail。</li>
        <li>append-only 记录让恢复过程可审计。</li>
      </ul>
    </div>

    <div class="panel p-6">
      <div class="mini-title">Durable worker memory</div>
      <p class="muted mt-2">项目本地知识，应该跨越单次 run 持续存在。</p>
      <ul class="mt-4 compact-list">
        <li>主根目录：<code>.agenthubmemory/</code></li>
        <li><code>TODO.md</code> 跟踪本地 execution 状态。</li>
        <li><code>journal/</code> 记录按时间顺序排列的工作日志。</li>
        <li><code>note/</code> 保存可复用的 heuristics 和经验。</li>
      </ul>
    </div>
  </div>

  <div class="panel panel-strong p-5 mt-6">
    <div class="mini-title">设计规则</div>
    <p class="mt-2">
      跨成员共享要经过 mailbox 或 channel pointer，而不是直接写对方文件系统。
      这样 ownership 才是显式的，也能避免静默的 context 污染。
    </p>
  </div>
</div>

---

<div class="slide-shell">
  <div class="aurora" style="opacity: 0.56"></div>
  <div class="eyebrow">Skills</div>
  <h1 class="!mt-3 !mb-6">Skills 是 runtime contract，不是 prompt 装饰</h1>

  <div class="grid grid-cols-3 gap-5">
    <div class="panel p-5">
      <div class="mini-title">Role-bound skills</div>
      <ul class="mt-3 compact-list">
        <li><code>team-agents-index</code></li>
        <li><code>team-leader-agents-index</code></li>
        <li><code>team-worker-agents-index</code></li>
        <li><code>team-leader-orchestrator</code></li>
        <li><code>team-worker-executor</code></li>
        <li><code>team-actor-mailbox</code></li>
      </ul>
    </div>
    <div class="panel p-5">
      <div class="mini-title">Phase skills</div>
      <ul class="mt-3 compact-list">
        <li><code>team-task-lifecycle</code></li>
        <li><code>team-deliberation-rules</code></li>
      </ul>
      <p class="muted mt-4">
        只在 phase 需要时加载，这样 context 大小才能保持可控。
      </p>
    </div>
    <div class="panel p-5">
      <div class="mini-title">Domain skills</div>
      <ul class="mt-3 compact-list">
        <li><code>tidb-optimizer-bugfix</code></li>
        <li><code>tidb-doc-finder</code></li>
        <li><code>tidb-profiler-analyzer</code></li>
        <li><code>context-management</code></li>
      </ul>
      <p class="muted mt-4">
        Domain skills 注入具体的 workflow、validation 规则和 artifact 约束。
      </p>
    </div>
  </div>

  <blockquote class="mt-6">
    设计目标是：在不让 prompt 膨胀的前提下获得精确性。先有 role baseline，再有 phase，最后只在需要时叠加 domain specialization。
  </blockquote>
</div>

---

<div class="slide-shell">
  <div class="aurora" style="opacity: 0.6"></div>
  <div class="eyebrow">TiDB</div>
  <h1 class="!mt-3 !mb-6">TiDB skill pack 把通用 agent 变成数据库工程师</h1>

  <div class="table-lite panel p-4">
    <table>
      <thead>
        <tr>
          <th>Skill</th>
          <th>它约束什么</th>
          <th>典型输出</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td><code>tidb-optimizer-bugfix</code></td>
          <td>minimal diff、hypothesis-driven debugging、regression-first validation</td>
          <td>聚焦 planner 的修复，以及可复用的调试笔记</td>
        </tr>
        <tr>
          <td><code>tidb-doc-finder</code></td>
          <td>以 repo 里的 <code>llms.txt</code> 作为 source-of-truth doc router</td>
          <td>带精确来源选择的 doc-grounded answer</td>
        </tr>
        <tr>
          <td><code>tidb-profiler-analyzer</code></td>
          <td>统一 profiler ingestion 和 top-path 分析方式</td>
          <td>从压缩 artifacts 中提炼出可行动的 CPU 或 heap 摘要</td>
        </tr>
      </tbody>
    </table>
  </div>

  <div class="grid grid-cols-2 gap-5 mt-6">
    <div class="panel p-5">
      <div class="mini-title">为什么重要</div>
      <ul class="mt-3 compact-list">
        <li>同一个 runtime 可以在 planning、doc lookup 和 optimizer repair 之间切换。</li>
        <li>validation 要求被编码进 skill，而不是每次 run 都重新教学。</li>
      </ul>
    </div>
    <div class="panel p-5">
      <div class="mini-title">工程效果</div>
      <ul class="mt-3 compact-list">
        <li>更高的 signal-to-token ratio。</li>
        <li>更低的泛化式、低质量 coding 行为风险。</li>
      </ul>
    </div>
  </div>
</div>

---

<div class="slide-shell">
  <div class="aurora" style="opacity: 0.58"></div>
  <div class="eyebrow">例子</div>
  <h1 class="!mt-3 !mb-6">一个端到端的 TiDB engineering loop</h1>

  <div class="grid grid-cols-[0.95fr_1.05fr] gap-6">
    <div class="panel p-5">
      <div class="mini-title">执行路径</div>
      <ol class="mt-3 pl-5">
        <li>Human 提出一个 optimizer bug fix 请求。</li>
        <li>Leader 拆解工作并创建 Task。</li>
        <li>Worker 使用 <code>tidb-optimizer-bugfix</code> 接手任务。</li>
        <li>Worker 把发现记录进 <code>.agenthubmemory</code>。</li>
        <li>Worker 通过 actor mailbox 回传 evidence。</li>
        <li>Leader review、集成并关闭该 Task。</li>
      </ol>
    </div>

    <div class="panel code-card p-5">
      <div class="mini-title mb-3">Worker 预期回传的内容</div>
      <ul class="compact-list">
        <li><code>status</code>：通常把 Task 推进到 <code>in_review</code>。</li>
        <li><code>result</code>：对变更内容或已证明结果的紧凑描述。</li>
        <li><code>evidence</code>：文件、测试、笔记或 reproduction artifact。</li>
        <li><code>next_action</code>：Leader 或 reviewer 下一步该做什么。</li>
      </ul>
      <p class="muted mt-4">
        重点不是漂亮的 JSON，而是带足够 evidence 的 deterministic handoff。
      </p>
    </div>
  </div>

  <div class="panel panel-strong p-5 mt-6">
    <div class="mini-title">核心洞察</div>
    <p class="mt-2">
      Team、skills 和 memory 不是彼此独立的 feature；它们是让复杂仓库工作在多轮交互中保持可靠的最小组合。
    </p>
  </div>
</div>

---

<div class="slide-shell">
  <div class="aurora" style="opacity: 0.62"></div>
  <div class="eyebrow">Shiro</div>
  <h1 class="!mt-3 !mb-6">Shiro 是一个面向 TiDB optimizer 的 fuzzing system</h1>

  <div class="grid grid-cols-4 gap-4">
    <div class="panel p-5">
      <div class="mini-title">Generator</div>
      <p class="muted mt-2">按权重切换 feature，生成随机 schema、data 和 SQL。</p>
    </div>
    <div class="panel p-5">
      <div class="mini-title">Oracles</div>
      <p class="muted mt-2">包含 NoREC、TLP、DQP、CERT、CODDTest、DQE，以及面向 GroundTruth 的路径。</p>
    </div>
    <div class="panel p-5">
      <div class="mini-title">Guidance</div>
      <p class="muted mt-2">用 QPG 追求 plan diversity，用 TQS 思路处理 join truth 和 guided exploration。</p>
    </div>
    <div class="panel p-5">
      <div class="mini-title">Artifacts</div>
      <p class="muted mt-2">包含 PLAN REPLAYER dump、minimized repro、case report 和可发布 manifest。</p>
    </div>
  </div>

  <div class="panel code-card p-5 mt-6">
    <div class="mini-title mb-3">入口命令很简单</div>
    <p class="mt-1">
      用 <code>go run ./cmd/shiro -config config.yaml</code> 启动，然后让 generation、
      oracle check、replay capture 和 reporting 持续推动这个闭环。
    </p>
    <p class="muted mt-4">
      真正重要的不是启动命令，而是从 generation 到 oracle check 再到 replayable evidence 的闭环。
    </p>
  </div>
</div>

---

<div class="slide-shell">
  <div class="aurora" style="opacity: 0.58"></div>
  <div class="eyebrow">引导</div>
  <h1 class="!mt-3 !mb-6">Shiro 不只是随机 SQL，而是 coverage model 和 truth model 的组合</h1>

  <div class="grid grid-cols-3 gap-5">
    <div class="panel p-5">
      <div class="mini-title">QPG</div>
      <p class="muted mt-2">
        Query Plan Guidance 把 EXPLAIN plan signature 当成 coverage signal。
      </p>
      <ul class="mt-3 compact-list">
        <li>跟踪重复 shape 和 operator sequence。</li>
        <li>当 coverage 停滞时，提高 joins、aggregates 和 subqueries 的权重。</li>
        <li>它是 coverage driver，不是 correctness oracle。</li>
      </ul>
    </div>
    <div class="panel p-5">
      <div class="mini-title">TQS ideas</div>
      <p class="muted mt-2">
        join testing 需要 data-guided schema、可计算的 truth，以及 guided exploration。
      </p>
      <ul class="mt-3 compact-list">
        <li>DSG 风格的 schema generation 能提升 join complexity。</li>
        <li>GroundTruth 用来检查 join correctness。</li>
        <li>KQE 风格的 guidance 会偏向覆盖不足的 join path。</li>
      </ul>
    </div>
    <div class="panel p-5">
      <div class="mini-title">Exact multiplicity path</div>
      <p class="muted mt-2">
        Bitmap truth 很便宜，但在非唯一 join key 上会少算。Shiro 增加了带上限控制的 hash-join counting path，
        在不把 memory 撑爆的情况下保持精确。
      </p>
    </div>
  </div>

  <div class="panel panel-strong p-5 mt-6">
    <div class="mini-title">工程效果</div>
    <p class="mt-2">
      Shiro 把 fuzzing 从 input diversity 推进到 plan diversity 加 join truth，这更接近 optimizer bug 真正藏身的地方。
    </p>
  </div>
</div>

---

<div class="slide-shell">
  <div class="aurora" style="opacity: 0.58"></div>
  <div class="eyebrow">AI 分诊</div>
  <h1 class="!mt-3 !mb-6">Shiro 还长出了一个 metadata 与 AI-assisted triage 平面</h1>

  <div class="grid grid-cols-6 gap-3 text-sm">
    <div class="flow-pill">Captured case</div>
    <div class="flow-pill">Artifacts</div>
    <div class="flow-pill">reports.json</div>
    <div class="flow-pill">Worker + D1</div>
    <div class="flow-pill">Similar search</div>
    <div class="flow-pill">AI rerank</div>
  </div>

  <div class="grid grid-cols-2 gap-5 mt-5">
    <div class="panel p-5">
      <div class="mini-title">元数据平面</div>
      <p class="muted mt-2">
        Cloudflare Worker 把轻量 metadata 放在 D1 中，而 artifacts 仍保留在 object storage。
      </p>
    </div>
    <div class="panel p-5">
      <div class="mini-title">AI 角度</div>
      <p class="muted mt-2">
        similar-bug search 可以在 top candidates 上叠加 AI explanation 和 rerank，把原始 fuzz 输出转成更快的人类分诊流程。
      </p>
    </div>
  </div>
</div>

---

<div class="slide-shell">
  <div class="aurora"></div>
  <div class="eyebrow">结论</div>
  <h1 class="!mt-3 !mb-8">这套栈说明了什么</h1>

  <div class="grid grid-cols-2 gap-5">
    <div class="panel p-6">
      <div class="mini-title">1. 协作需要 protocol</div>
      <p class="muted mt-2">
        只有当 message transport、ownership 和 replay 都是显式的，Team 行为才会可靠。
      </p>
    </div>
    <div class="panel p-6">
      <div class="mini-title">2. 专长需要 skills</div>
      <p class="muted mt-2">
        可复用的 skill contract，比不断膨胀的 system prompt 更适合作为扩展单位。
      </p>
    </div>
    <div class="panel p-6">
      <div class="mini-title">3. 长任务需要 memory 设计</div>
      <p class="muted mt-2">
        stable prefix、append-only log 和 pointerized artifact，才是长 run 可恢复的基础。
      </p>
    </div>
    <div class="panel p-6">
      <div class="mini-title">4. 领域价值来自闭环</div>
      <p class="muted mt-2">
        Shiro 之所以重要，是因为它把 bug discovery、replay、report 和 triage 串成了闭环。
      </p>
    </div>
  </div>

  <div class="panel panel-strong p-6 mt-6">
    <div class="text-3xl font-semibold leading-tight">
      真正的产品不是“一个 agent”，而是能让多个 agent、tool 和 artifact 随时间持续复利的工程系统。
    </div>
  </div>
</div>

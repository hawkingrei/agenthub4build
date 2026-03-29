---
theme: seriph
title: Harness Engineer：Agent Team 在 TiDB 优化器研发中的应用
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
  <div class="eyebrow">技术分享</div>
  <div class="max-w-5xl mt-8">
    <h1 class="!text-6xl !leading-tight !mb-6">Harness Engineer：Agent Team 在 TiDB 优化器研发中的应用</h1>
    <p class="text-2xl leading-10 max-w-4xl">
      以 AgentHub 作为协作底座，以 TiDB skills 作为领域能力，以 memory 维持长周期连续性，
      并用 Shiro 构建优化器 bug 发现与分诊闭环。
    </p>
  </div>

  <div class="grid grid-cols-2 gap-4 max-w-4xl mt-12">
    <div class="panel p-5">
      <div class="eyebrow">范围</div>
      <div class="mt-2 text-lg font-semibold">Agent Team、actor system、workflow、memory、TiDB skills、Shiro</div>
    </div>
    <div class="panel p-5">
      <div class="eyebrow">核心判断</div>
      <div class="mt-2 text-lg font-semibold">真正有用的 AI 系统，不是更大的 prompt，而是协作、专长、持久状态和领域闭环的组合</div>
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
  <h1 class="!mt-3 !mb-8">今天主要讲四个技术问题</h1>

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
        人不持续介入时，任务如何仍然长期推进，并在需要时恢复上下文。
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
        单 agent demo 优化的是一次回答；这里更关注协作效率、约束执行、持久记忆和反馈闭环。
      </p>
    </div>
  </div>
</div>

---

<div class="slide-shell">
  <div class="aurora" style="opacity: 0.62"></div>
  <div class="eyebrow">AgentHub</div>
  <h1 class="!mt-3 !mb-6">AgentHub 的特色，来自三次演化</h1>

  <div class="grid grid-cols-2 gap-6">
    <div class="panel p-6">
      <div class="mini-title">今天的三个特色</div>
      <ul class="mt-3 compact-list">
        <li><code>Agent Team</code>：把复杂研发任务拆成 Leader / Worker 协作，而不是让单个 agent 硬扛。</li>
        <li><code>Actor system</code>：用 mailbox、task 和 run 把协作变成可回放、可审计的协议。</li>
        <li><code>Remote agent node</code>：把 repo checkout、build 和 test 分散到多台机器上，专门支撑 TiDB 这类大仓库的并发开发与并发测试。</li>
      </ul>
    </div>
    <div class="panel p-6">
      <div class="mini-title">演化路径</div>
      <ul class="mt-3 compact-list">
        <li>最初，AgentHub 更像一个面向 ACP agent 的 remote manager。</li>
        <li>随后，它演进成 <code>Agent Team</code>，解决复杂任务的分工、协作和恢复。</li>
        <li>在 TiDB 这类超大 repo 场景里，又补上了 <code>remote agent node</code>。</li>
        <li>这样 worker 就不必都挤在一台机器上抢 CPU、磁盘和编译缓存。</li>
      </ul>
    </div>
  </div>

  <div class="panel p-6 mt-6">
    <div class="mini-title">为什么会继续演化</div>
    <div class="grid grid-cols-3 gap-4 mt-4">
      <div>
        <div class="eyebrow">复杂任务</div>
        <div class="font-semibold mt-1">单个 agent 不够</div>
        <p class="muted mt-2">一旦同时涉及 planning、execution、review 和 reporting，单 agent 很快就会失控。</p>
      </div>
      <div>
        <div class="eyebrow">大仓库</div>
        <div class="font-semibold mt-1">单机并发成本太高</div>
        <p class="muted mt-2">TiDB repo 很大，多 worktree、多 build、多测试并发时，单台电脑很容易成为瓶颈。</p>
      </div>
      <div>
        <div class="eyebrow">工程目标</div>
        <div class="font-semibold mt-1">既要协作，也要落地</div>
        <p class="muted mt-2">对人要保留自然对话，对机器要保留明确 ownership、协议和可回放执行。</p>
      </div>
    </div>
  </div>
</div>

---

<div class="slide-shell">
  <div class="aurora" style="opacity: 0.6"></div>
  <div class="eyebrow">Harness</div>
  <h1 class="!mt-3 !mb-6">把 AgentHub 放进 Harness Engineering 框架里</h1>

  <div class="grid grid-cols-2 gap-5">
    <div class="panel p-5">
      <div class="mini-title">Context Architecture</div>
      <p class="muted mt-2">
        Agent 只拿当前 Task 真正需要的上下文。在 TiDB optimizer 场景里，这意味着只暴露相关 planner 代码、
        测试、文档和 repro artifacts，而不是整仓库一起塞进 prompt。
      </p>
    </div>
    <div class="panel p-5">
      <div class="mini-title">Agent Specialization</div>
      <p class="muted mt-2">
        受限工具、明确职责的专门 agent，优于拥有全部权限的通用 agent。Leader、Worker、TiDB domain skills
        和 remote agent node 一起形成这层 specialization，尤其适合拆开 TiDB 的并发测试压力。
      </p>
    </div>
    <div class="panel p-5">
      <div class="mini-title">Persistent Memory</div>
      <p class="muted mt-2">
        进度持久化在文件系统而不是上下文窗口里。<code>.cache/context</code> 负责 runtime continuity，
        <code>.agenthubmemory</code> 负责 durable notes，新会话从制品重建上下文。
      </p>
    </div>
    <div class="panel p-5">
      <div class="mini-title">Structured Execution</div>
      <p class="muted mt-2">
        把思考、执行和验证拆开。Task、Trigger、CI、Linter 和 human review 共同保证执行沿着可验证的计划推进。
      </p>
    </div>
  </div>

  <div class="panel panel-strong p-5 mt-6">
    <div class="mini-title">核心判断</div>
    <p class="mt-2">
      AgentHub 不是一个“会写代码的 agent”，而是把上下文、专长、记忆和执行结构化之后形成的工程 harness。
    </p>
  </div>
</div>

---

<div class="slide-shell">
  <div class="aurora" style="opacity: 0.58"></div>
  <div class="eyebrow">Harness 原则</div>
  <h1 class="!mt-3 !mb-6">把 Harness 原则映射到 TiDB 场景</h1>

  <div class="grid grid-cols-2 gap-5">
    <div class="panel p-5">
      <div class="mini-title">1. 设计环境，而非编写代码</div>
      <p class="muted mt-2">
        当 optimizer agent 卡住时，不是继续堆 prompt，而是补 plan replayer、statistics dump、repro harness、remote node 这类环境能力。
      </p>
    </div>
    <div class="panel p-5">
      <div class="mini-title">2. 机械化地执行约束</div>
      <p class="muted mt-2">
        在 TiDB 这种大仓库里，关键不是写出一条漂亮分层图，而是把“哪些代码不该互相依赖”“哪些测试必须补”
        这类约束机械化下来；如果能做到，报错最好还能直接教 agent 怎么修。
      </p>
    </div>
    <div class="panel p-5">
      <div class="mini-title">3. Repo 是唯一事实源</div>
      <p class="muted mt-2">
        skills、回归测试、minimized repro、plan replayer、调试笔记都放进仓库；只存在于 Slack 或 Docs 的知识对 agent 等于不存在。
      </p>
    </div>
    <div class="panel p-5">
      <div class="mini-title">4. 把可观测性接给 agent</div>
      <p class="muted mt-2">
        <code>EXPLAIN ANALYZE</code>、optimizer trace、statement summary、慢日志、profiler、CI logs 都应该可被 agent 查询，这样 plan diff、性能回退和 flaky case 才可度量。
      </p>
    </div>
  </div>

  <div class="panel p-5 mt-5">
    <div class="mini-title">5. 对抗熵</div>
    <p class="muted mt-2">
      AI 生成的 notes、tests、SQL repro 和 fuzz outputs 不能直接堆积；它们要么被清理掉，要么被最小化并升级成稳定的 regression case。
    </p>
  </div>

  <div class="panel panel-strong p-5 mt-6">
    <div class="mini-title">为什么这很重要</div>
    <p class="mt-2">
      对 TiDB 这种大仓库来说，真正决定 Agent 上限的，不是模型会不会写代码，而是环境是否能持续、机械化地把正确行为推到它面前。
    </p>
  </div>
</div>

---

<div class="slide-shell">
  <div class="aurora" style="opacity: 0.56"></div>
  <div class="eyebrow">架构</div>
  <h1 class="!mt-3 !mb-6">Actor system 把协作拆成三个平面</h1>

  <div class="flex flex-wrap gap-3 text-sm">
    <div class="flow-pill">Human intent</div>
    <div class="flow-pill">Leader</div>
    <div class="flow-pill">Task</div>
    <div class="flow-pill">Mailbox</div>
    <div class="flow-pill">Worker</div>
    <div class="flow-pill">Evidence</div>
    <div class="flow-pill">Review</div>
  </div>

  <div class="grid grid-cols-3 gap-5 mt-6">
    <div class="panel p-5">
      <div class="mini-title">1. Coordination plane</div>
      <p class="muted mt-2">
        Leader 直接面对人类需求，把 conversation 收敛成 Task。
      </p>
      <ul class="mt-4 compact-list">
        <li>Conversation 承载目标、约束和建议。</li>
        <li>Task 是 canonical execution unit。</li>
        <li>Trigger 负责等待与 context switch。</li>
      </ul>
    </div>
    <div class="panel p-5">
      <div class="mini-title">2. Delivery plane</div>
      <p class="muted mt-2">
        协作不直接依赖聊天记录，而是依赖 mailbox transport。
      </p>
      <ul class="mt-4 compact-list">
        <li>交付始终遵循 <code>send -> inbox -> ack</code>。</li>
        <li><code>pending_count</code> 提供当前未处理消息的个数。</li>
        <li>channel event 负责提醒，mailbox ack 才是完成信号。</li>
      </ul>
    </div>
    <div class="panel p-5">
      <div class="mini-title">3. Execution plane</div>
      <p class="muted mt-2">
        Worker 围绕 Task 执行，复杂度由 skills、memory 和 remote nodes 吸收。
      </p>
      <ul class="mt-4 compact-list">
        <li>skills 决定角色和领域行为。</li>
        <li>memory 负责连续性与经验沉淀。</li>
        <li>remote nodes 专门用来承接 TiDB 大仓库的并发测试和重型执行。</li>
      </ul>
    </div>
  </div>

  <div class="grid grid-cols-3 gap-4 mt-6">
    <div class="panel p-4">
      <div class="mini-title">Identity</div>
      <p class="muted mt-2"><code>actor_id</code> 是 canonical identity；<code>run_id</code> 用来切分 delivery 和 replay。</p>
    </div>
    <div class="panel p-4">
      <div class="mini-title">Reliability</div>
      <p class="muted mt-2">采用 at-least-once delivery，并要求 send / ack 具备 idempotent 语义。</p>
    </div>
    <div class="panel p-4">
      <div class="mini-title">Authority</div>
      <p class="muted mt-2">Main DB 是真相来源；event bus 提供实时 fan-out，但不负责 execution truth。</p>
    </div>
  </div>
</div>

---

<div class="slide-shell">
  <div class="aurora" style="opacity: 0.58"></div>
  <div class="eyebrow">协议</div>
  <h1 class="!mt-3 !mb-6">Mailbox-first 协作协议：inbox / ack / send</h1>

  <div class="grid grid-cols-[1.15fr_0.85fr] gap-6">
    <div class="panel code-card p-5">
      <div class="mini-title mb-3">三条核心命令</div>
      <div class="rounded-4 bg-stone-950 text-amber-50 p-4">
        <div class="font-mono text-sm leading-6">agenthub actor inbox --limit 50</div>
        <div class="font-mono text-sm leading-6 mt-2">agenthub actor ack --message-id ...</div>
        <div class="font-mono text-sm leading-6 mt-2">agenthub actor send --to-actor-id ...</div>
      </div>
      <p class="muted mt-4">
        这个 contract 被有意收窄：读取工作、确认 evidence、发送下一状态。
      </p>
    </div>
    <div class="panel p-5">
      <div class="mini-title">为什么重要</div>
      <ul class="mt-3 compact-list">
        <li>稳定的 surface 意味着更小的 prompt 和更少的隐藏执行路径。</li>
        <li><code>run_id</code> 让 replay 保持 deterministic。</li>
        <li><code>pending_count</code> 提供一个低成本的未处理消息计数。</li>
        <li>channel event 提供实时感知，降低轮询成本；执行完成仍以 mailbox ack 为准。</li>
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
  <h1 class="!mt-3 !mb-8">任务交给 Leader 后，workflow 才能持续推进</h1>

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
      人不需要一直盯住执行细节。目标一旦交给 Leader，Leader 就可以围绕 Task 持续拆解、分派、跟进和集成，
      直到需要新的判断时再把上下文带回给人。
    </p>
  </div>
</div>

---

<div class="slide-shell">
  <div class="aurora" style="opacity: 0.6"></div>
  <div class="eyebrow">角色</div>
  <h1 class="!mt-3 !mb-6">Leader 面向人，Worker 面向执行，Task 稳定协作边界</h1>

  <div class="grid grid-cols-3 gap-5">
    <div class="panel p-5">
      <div class="mini-title">Leader</div>
      <ul class="mt-3 compact-list">
        <li>直接听取人的目标、建议和约束，持续保持对齐。</li>
        <li>把开放式需求收敛成可执行的 Task。</li>
        <li>持续跟进 worker 进度，督促执行、解除阻塞并完成集成。</li>
      </ul>
    </div>
    <div class="panel p-5">
      <div class="mini-title">Worker</div>
      <ul class="mt-3 compact-list">
        <li>围绕分配到的 Task 专注 execution，而不是反复打断人。</li>
        <li>生产 evidence、更新 status，并及时暴露 blocker。</li>
        <li>需要时可以运行在本地，也可以运行在 remote agent node 上，把 TiDB 的并发测试拆到多台机器。</li>
      </ul>
    </div>
    <div class="panel p-5">
      <div class="mini-title">Task</div>
      <ul class="mt-3 compact-list">
        <li>Task 是 human intent 和 machine execution 之间的 canonical abstraction。</li>
        <li>它固定了 owner、status、acceptance criteria 和 evidence。</li>
        <li>即使中途切换 context，Team 也能围绕 Task 恢复工作。</li>
      </ul>
    </div>
  </div>

  <div class="flex flex-wrap gap-3 mt-6 text-sm">
    <div class="flow-pill">Human</div>
    <div class="flow-pill">Leader</div>
    <div class="flow-pill">Task</div>
    <div class="flow-pill">Worker</div>
    <div class="flow-pill">Evidence</div>
    <div class="flow-pill">Leader</div>
    <div class="flow-pill">Answer</div>
  </div>

  <div class="panel panel-strong p-5 mt-6">
    <div class="mini-title">为什么 Task 很关键</div>
    <p class="mt-2">
      Conversation 可以变化，Task 不能漂。Leader 直接对人负责，Worker 直接对 Task 负责，而 Task 负责把协作闭环稳定下来。
    </p>
  </div>
</div>

---

<div class="slide-shell">
  <div class="aurora" style="opacity: 0.58"></div>
  <div class="eyebrow">Trigger</div>
  <h1 class="!mt-3 !mb-6">Trigger 把等待变成可调度的工作</h1>

  <div class="panel p-5">
    <div class="mini-title">抽象本身</div>
    <ul class="mt-3 compact-list">
      <li>Trigger 不是简单提醒，而是“条件满足后恢复某个 Task”的抽象。</li>
      <li>条件可以是时间，也可以是外部事件。</li>
      <li>这样 Team 就能在等待期间切去做别的 Task，而不是空等。</li>
    </ul>
  </div>

  <div class="grid grid-cols-2 gap-6 mt-6">
    <div class="panel p-5">
      <div class="mini-title">时间型 trigger</div>
      <ol class="mt-3 pl-5">
        <li>已知某个测试通常会跑 10 分钟。</li>
        <li>先创建一个 <code>T+10m</code> 的 trigger。</li>
        <li>这 10 分钟内切去处理别的 Task。</li>
        <li>10 分钟后收到提醒，再回到原 Task 检查结果并决定下一步。</li>
      </ol>
      <div class="flex flex-wrap gap-2 mt-4 text-sm">
        <div class="flow-pill">start test</div>
        <div class="flow-pill">set T+10m</div>
        <div class="flow-pill">switch task</div>
        <div class="flow-pill">resume context</div>
      </div>
    </div>
    <div class="panel p-5">
      <div class="mini-title">事件型 trigger</div>
      <ol class="mt-3 pl-5">
        <li>例如监听 <code>GitHub webhook</code>，等待 CI 完成、PR review 或 issue 更新。</li>
        <li>事件没到之前，Leader 不需要一直盯着页面刷新。</li>
        <li>事件一到，就恢复对应 Task，继续 review、merge 或修复流程。</li>
        <li>Trigger 把外部系统事件自然接到 Team workflow 里。</li>
      </ol>
      <div class="flex flex-wrap gap-2 mt-4 text-sm">
        <div class="flow-pill">wait webhook</div>
        <div class="flow-pill">event arrives</div>
        <div class="flow-pill">resume task</div>
        <div class="flow-pill">continue workflow</div>
      </div>
    </div>
  </div>

  <div class="panel panel-strong p-5 mt-6">
    <div class="mini-title">价值</div>
    <p class="mt-2">
      对大仓库研发来说，Trigger 的价值不是提醒本身，而是把等待显式化，让 timer、webhook 和 context switch 成为一等公民。
    </p>
  </div>
</div>

---

<div class="slide-shell">
  <div class="aurora" style="opacity: 0.6"></div>
  <div class="eyebrow">Memory</div>
  <h1 class="!mt-3 !mb-6">Memory management</h1>

  <div class="grid grid-cols-3 gap-5">
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
    <div class="panel p-6">
      <div class="mini-title">Shared cloud memory</div>
      <p class="muted mt-2"><code>mem9</code> 适合跨机器、跨 agent 的共享持久记忆。</p>
      <ul class="mt-4 compact-list">
        <li>memory 被放进独立 server，而不是绑在某一台开发机上。</li>
        <li>多个 agent 指向同一个 tenant 时，可以共享同一个 memory pool。</li>
        <li>agent plugin 可以保持 stateless，而底层 memory service 由 TiDB-backed store 支撑。</li>
      </ul>
    </div>
  </div>

  <div class="panel panel-strong p-5 mt-6">
    <div class="mini-title">设计规则</div>
    <p class="mt-2">
      本地 <code>.agenthubmemory</code> 适合保存 worker 的项目内记忆；像 <code>mem9</code> 这样的 shared memory
      更适合跨机器、跨 agent 的长期共享。跨成员共享仍然应该经过 mailbox、pointer 或受控 memory service，
      不能直接写对方文件系统。
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
      <p class="muted mt-2">
        跟角色绑定，定义 Leader / Worker 从启动开始就遵守的基线职责。
      </p>
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
      <p class="muted mt-2">
        跟当前 phase 绑定，只在分析、评审或集成等阶段按需加载。
      </p>
      <ul class="mt-3 compact-list">
        <li><code>team-task-lifecycle</code></li>
        <li><code>team-deliberation-rules</code></li>
      </ul>
    </div>
    <div class="panel p-5">
      <div class="mini-title">Domain skills</div>
      <p class="muted mt-2">
        跟领域绑定，把 TiDB 的 workflow、validation 和 artifact 约束带进 runtime。
      </p>
      <ul class="mt-3 compact-list">
        <li><code>tidb-optimizer-bugfix</code></li>
        <li><code>agent-rules</code></li>
        <li><code>tidb-profiler-analyzer</code></li>
        <li><code>context-management</code></li>
      </ul>
    </div>
  </div>

  <blockquote class="mt-6">
    设计目标是：在不让 prompt 膨胀的前提下，让行为足够精确。先有 role baseline，再有 phase，最后只在需要时叠加 domain specialization。
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
          <td><code>agent-rules</code></td>
          <td>把 TiDB 研发约束、常见流程和工程规则沉淀成可直接复用的 rules</td>
          <td>更稳定的任务约束、执行边界和 code review / validation 习惯</td>
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
        <li>更低的空泛推理和低质量 coding 风险。</li>
      </ul>
    </div>
  </div>
</div>

---

<div class="slide-shell">
  <div class="aurora" style="opacity: 0.58"></div>
  <div class="eyebrow">例子</div>
  <h1 class="!mt-3 !mb-6">一个端到端的 TiDB engineering loop 示例</h1>

  <div class="grid grid-cols-[0.95fr_1.05fr] gap-6">
    <div class="panel p-5">
      <div class="mini-title">执行路径</div>
      <ol class="mt-3 pl-5">
        <li>Human 提出一个 optimizer bug fix 请求。</li>
        <li>Leader 拆解工作并创建 Task。</li>
        <li>Worker 使用 <code>tidb-optimizer-bugfix</code> 接手任务。</li>
        <li>Worker 把局部发现沉淀到 <code>.agenthubmemory</code>。</li>
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
        重点不是漂亮的 JSON，而是有足够 evidence 的 deterministic handoff。
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
  <h1 class="!mt-3 !mb-6">Shiro 是面向 TiDB optimizer 的 fuzzing system</h1>

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
    <div class="mini-title mb-3">入口命令并不复杂</div>
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
        在不把 memory 撑爆的前提下保持精确。
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
  <div class="eyebrow">CI</div>
  <h1 class="!mt-3 !mb-6">Fuzz 进了 CI，才会从工具变成基础设施</h1>

  <div class="grid grid-cols-3 gap-5">
    <div class="panel p-5">
      <div class="mini-title">PR checks</div>
      <p class="muted mt-2">
        先跑足够快、足够确定的检查，例如相关单测、planner regression、已有 repro case replay。
      </p>
    </div>
    <div class="panel p-5">
      <div class="mini-title">Scheduled fuzz</div>
      <p class="muted mt-2">
        把更重的 fuzz、differential check 和长时间 guided exploration 放进定时 CI 或专门 lane。
      </p>
    </div>
    <div class="panel p-5">
      <div class="mini-title">Failure promotion</div>
      <p class="muted mt-2">
        新发现的问题不能停留在原始 fuzz output；要被最小化、可回放，并提升成仓库里的稳定 regression case。
      </p>
    </div>
  </div>

  <div class="flex flex-wrap gap-3 mt-6 text-sm">
    <div class="flow-pill">commit</div>
    <div class="flow-pill">CI checks</div>
    <div class="flow-pill">scheduled fuzz</div>
    <div class="flow-pill">capture failure</div>
    <div class="flow-pill">minimize</div>
    <div class="flow-pill">replay in CI</div>
  </div>

  <div class="panel panel-strong p-5 mt-6">
    <div class="mini-title">TiDB 里的价值</div>
    <p class="mt-2">
      对 optimizer 来说，真正重要的不是“跑过一次 fuzz”，而是把 fuzz 发现的问题持续接回 CI，
      让同类回归以后再也进不来。
    </p>
  </div>
</div>

---

<div class="slide-shell">
  <div class="aurora" style="opacity: 0.58"></div>
  <div class="eyebrow">AI 分诊</div>
  <h1 class="!mt-3 !mb-6">Shiro 还扩展出了一个 metadata 与 AI-assisted triage 平面</h1>

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
        similar-bug search 可以在 top candidates 上叠加 AI explanation 与 rerank，把原始 fuzz 输出转成更快的人类分诊流程。
      </p>
    </div>
  </div>
</div>

---

<div class="slide-shell">
  <div class="aurora"></div>
  <div class="eyebrow">结论</div>
  <h1 class="!mt-3 !mb-8">Harness 在 TiDB 里的最终形态</h1>

  <div class="grid grid-cols-4 gap-3 text-sm">
    <div class="flow-pill">Context Architecture</div>
    <div class="flow-pill">Agent Specialization</div>
    <div class="flow-pill">Persistent Memory</div>
    <div class="flow-pill">Structured Execution</div>
  </div>

  <div class="grid grid-cols-4 gap-5 mt-6">
    <div class="panel p-5">
      <div class="mini-title">AgentHub</div>
      <p class="muted mt-2">
        用 Leader、Worker、Task、Trigger 和 actor protocol 把上下文收窄到当前任务。
      </p>
    </div>
    <div class="panel p-5">
      <div class="mini-title">TiDB skills</div>
      <p class="muted mt-2">
        用受限工具和领域 workflow，把通用 agent 收敛成数据库工程师。
      </p>
    </div>
    <div class="panel p-5">
      <div class="mini-title">Filesystem memory</div>
      <p class="muted mt-2">
        用 <code>.cache/context</code> 和 <code>.agenthubmemory</code> 把进度与经验持续留下来。
      </p>
    </div>
    <div class="panel p-5">
      <div class="mini-title">Shiro + CI</div>
      <p class="muted mt-2">
        用 fuzz、replay、triage 和 regression promotion 构成持续反馈闭环。
      </p>
    </div>
  </div>

  <div class="flex flex-wrap gap-3 mt-6 text-sm">
    <div class="flow-pill">Human intent</div>
    <div class="flow-pill">AgentHub</div>
    <div class="flow-pill">TiDB execution</div>
    <div class="flow-pill">Shiro / CI feedback</div>
    <div class="flow-pill">Repo artifacts</div>
    <div class="flow-pill">Next task</div>
  </div>

  <div class="panel panel-strong p-6 mt-6">
    <div class="text-3xl font-semibold leading-tight">
      真正的产品不是“一个 agent”，而是一个能把人类意图、Agent 执行、仓库制品和 CI 反馈持续闭环起来的工程 harness。
    </div>
  </div>
</div>

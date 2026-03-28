---
theme: seriph
title: From Agent Team to AI Fuzzing
info: |
  A Slidev deck on AgentHub team runtime, TiDB skills, memory design, and Shiro.
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
  <div class="eyebrow">Engineering Systems Deck</div>
  <div class="max-w-5xl mt-8">
    <h1 class="!text-6xl !leading-tight !mb-6">From Agent Team to AI Fuzzing</h1>
    <p class="text-2xl leading-10 max-w-4xl">
      AgentHub as the coordination substrate, TiDB skills as domain specialization,
      memory as long-horizon continuity, and Shiro as the optimizer-bug discovery engine.
    </p>
  </div>

  <div class="grid grid-cols-2 gap-4 max-w-4xl mt-12">
    <div class="panel p-5">
      <div class="eyebrow">Focus</div>
      <div class="mt-2 text-lg font-semibold">Agent team, actor protocol, workflow, memory, TiDB skills, Shiro</div>
    </div>
    <div class="panel p-5">
      <div class="eyebrow">Thesis</div>
      <div class="mt-2 text-lg font-semibold">Useful AI systems are built from coordination + specialization + durable state + domain loops</div>
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
  <div class="eyebrow">Agenda</div>
  <h1 class="!mt-3 !mb-8">This stack is four systems, not one product</h1>

  <div class="grid grid-cols-2 gap-5">
    <div class="panel p-6">
      <div class="metric">01</div>
      <div class="mini-title mt-3">Coordination</div>
      <p class="mt-2 muted">
        How multiple agents share work without turning the run into nondeterministic chat.
      </p>
    </div>
    <div class="panel p-6">
      <div class="metric">02</div>
      <div class="mini-title mt-3">Specialization</div>
      <p class="mt-2 muted">
        How reusable skills keep prompts small and domain behavior precise.
      </p>
    </div>
    <div class="panel p-6">
      <div class="metric">03</div>
      <div class="mini-title mt-3">Continuity</div>
      <p class="mt-2 muted">
        How memory separates volatile runtime state from durable project knowledge.
      </p>
    </div>
    <div class="panel p-6">
      <div class="metric">04</div>
      <div class="mini-title mt-3">Domain Loop</div>
      <p class="mt-2 muted">
        How Shiro turns optimizer testing into a guided, replayable, triage-ready system.
      </p>
    </div>
  </div>

  <div class="panel panel-strong p-6 mt-6">
    <div class="quote-line">
      <div class="mini-title">Key framing</div>
      <p class="mt-2">
        Single-agent demos optimize for one answer. Production engineering systems optimize for
        delegation, replay, evidence, and recovery.
      </p>
    </div>
  </div>
</div>

---

<div class="slide-shell">
  <div class="aurora" style="opacity: 0.62"></div>
  <div class="eyebrow">Why Team</div>
  <h1 class="!mt-3 !mb-6">AgentHub moves from one clever agent to a disciplined team</h1>

  <div class="grid grid-cols-2 gap-6">
    <div class="panel p-6">
      <div class="mini-title">Without a team model</div>
      <ul class="mt-3 compact-list">
        <li>One prompt must carry planning, execution, review, and reporting at once.</li>
        <li>Context fills up with logs, half-decisions, and duplicated status updates.</li>
        <li>Human coordination and execution control become mixed together.</li>
        <li>Failure recovery is hard because ownership is implicit.</li>
      </ul>
    </div>
    <div class="panel p-6">
      <div class="mini-title">With the AgentHub model</div>
      <ul class="mt-3 compact-list">
        <li>Leader owns planning, decomposition, review, and synthesis.</li>
        <li>Workers own execution, evidence production, and local notes.</li>
        <li>Conversation stays human-friendly; tasks and runs stay machine-auditable.</li>
        <li>Mailbox evidence becomes the durable record of cross-agent work.</li>
      </ul>
    </div>
  </div>

  <div class="panel p-6 mt-6">
    <div class="mini-title">Canonical Team model</div>
    <div class="grid grid-cols-3 gap-4 mt-4">
      <div>
        <div class="eyebrow">Layer 1</div>
        <div class="font-semibold mt-1">Conversation</div>
        <p class="muted mt-2">Human-facing lane for goals, constraints, approvals, and questions.</p>
      </div>
      <div>
        <div class="eyebrow">Layer 2</div>
        <div class="font-semibold mt-1">Task Ownership</div>
        <p class="muted mt-2">Leader turns agreed work into canonical tasks with explicit ownership.</p>
      </div>
      <div>
        <div class="eyebrow">Layer 3</div>
        <div class="font-semibold mt-1">Execution Telemetry</div>
        <p class="muted mt-2">Runs and steps are debugging artifacts, not the main collaboration unit.</p>
      </div>
    </div>
  </div>
</div>

---

<div class="slide-shell">
  <div class="aurora" style="opacity: 0.56"></div>
  <div class="eyebrow">Architecture</div>
  <h1 class="!mt-3 !mb-6">Actor is the coordination substrate</h1>

  <div class="grid grid-cols-4 gap-4">
    <div class="panel p-4">
      <div class="mini-title">Conversation</div>
      <p class="muted mt-2">Human goals and feedback stay in the shared lane.</p>
    </div>
    <div class="panel p-4">
      <div class="mini-title">Task / Run</div>
      <p class="muted mt-2">Leader converts intent into explicit work objects.</p>
    </div>
    <div class="panel p-4">
      <div class="mini-title">Actor Mailbox</div>
      <p class="muted mt-2">Cross-agent delivery is always <code>send -> inbox -> ack</code>.</p>
    </div>
    <div class="panel p-4">
      <div class="mini-title">Workers</div>
      <p class="muted mt-2">Execution and evidence move through role-specific agents.</p>
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
      <p class="muted mt-2">Role, phase, and domain skills shape behavior without bloating one giant prompt.</p>
    </div>
    <div class="panel p-4">
      <div class="mini-title">Memory</div>
      <p class="muted mt-2"><code>.cache/context</code> holds runtime continuity; <code>.agenthubmemory</code> holds durable notes.</p>
    </div>
    <div class="panel p-4">
      <div class="mini-title">Event bus</div>
      <p class="muted mt-2">Realtime visibility is separate from authoritative mailbox completion.</p>
    </div>
  </div>

  <div class="grid grid-cols-3 gap-4 mt-5">
    <div class="panel p-4">
      <div class="mini-title">Identity</div>
      <p class="muted mt-2"><code>actor_id</code> is canonical. <code>run_id</code> partitions replay and delivery.</p>
    </div>
    <div class="panel p-4">
      <div class="mini-title">Reliability</div>
      <p class="muted mt-2">At-least-once delivery with idempotent send and ack semantics.</p>
    </div>
    <div class="panel p-4">
      <div class="mini-title">Authority</div>
      <p class="muted mt-2">Main DB is truth; event bus is for realtime fan-out, not execution truth.</p>
    </div>
  </div>
</div>

---

<div class="slide-shell">
  <div class="aurora" style="opacity: 0.58"></div>
  <div class="eyebrow">Protocol</div>
  <h1 class="!mt-3 !mb-6">The actor loop is deliberately small</h1>

  <div class="grid grid-cols-[1.15fr_0.85fr] gap-6">
    <div class="panel code-card p-5">
      <div class="mini-title mb-3">Mailbox-first coordination</div>
      <div class="rounded-4 bg-stone-950 text-amber-50 font-mono text-sm leading-6 p-4 whitespace-pre">agenthub actor inbox --limit 50
agenthub actor ack --message-id [message_id]
agenthub actor send --to-actor-id [member_id] --text-file update.md
agenthub actor send --channel-id all --text-file broadcast.md</div>
      <p class="muted mt-4">
        The contract is intentionally narrow: read work, acknowledge evidence, send the next state.
      </p>
    </div>

    <div class="panel p-5">
      <div class="mini-title">Why this matters</div>
      <ul class="mt-3 compact-list">
        <li>Stable surface means smaller prompts and fewer hidden execution paths.</li>
        <li><code>run_id</code> keeps replay deterministic.</li>
        <li><code>pending_count</code> gives a cheap unread snapshot.</li>
        <li>Channel events improve UX, but mailbox ack remains the completion signal.</li>
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
  <div class="eyebrow">Workflow</div>
  <h1 class="!mt-3 !mb-8">Six phases keep team runs legible</h1>

  <div class="grid grid-cols-3 gap-4">
    <div class="panel p-5">
      <div class="metric">1</div>
      <div class="mini-title mt-3">Team formation</div>
      <p class="muted mt-2">Confirm roster, capability gaps, operating assumptions.</p>
    </div>
    <div class="panel p-5">
      <div class="metric">2</div>
      <div class="mini-title mt-3">Task analysis</div>
      <p class="muted mt-2">Decompose goals, constraints, risks, and acceptance criteria.</p>
    </div>
    <div class="panel p-5">
      <div class="metric">3</div>
      <div class="mini-title mt-3">Role assignment</div>
      <p class="muted mt-2">Bind concrete work to the worker card that best fits the task.</p>
    </div>
    <div class="panel p-5">
      <div class="metric">4</div>
      <div class="mini-title mt-3">Communication</div>
      <p class="muted mt-2">Drive checkpoints, unblock execution, keep evidence fresh.</p>
    </div>
    <div class="panel p-5">
      <div class="metric">5</div>
      <div class="mini-title mt-3">Consensus</div>
      <p class="muted mt-2">Compare evidence, settle conflicts, lock decisions.</p>
    </div>
    <div class="panel p-5">
      <div class="metric">6</div>
      <div class="mini-title mt-3">Integration</div>
      <p class="muted mt-2">Merge outputs into one human-facing answer and close the loop.</p>
    </div>
  </div>

  <div class="panel panel-strong p-5 mt-6">
    <div class="mini-title">Important design choice</div>
    <p class="mt-2">
      Conversation is not the canonical task ledger. The canonical execution unit is the task,
      and the canonical delivery evidence is the mailbox exchange around that task.
    </p>
  </div>
</div>

---

<div class="slide-shell">
  <div class="aurora" style="opacity: 0.6"></div>
  <div class="eyebrow">Memory</div>
  <h1 class="!mt-3 !mb-6">Memory management is split by lifetime, not by convenience</h1>

  <div class="grid grid-cols-2 gap-6">
    <div class="panel p-6">
      <div class="mini-title">Runtime continuity</div>
      <p class="muted mt-2">Ephemeral, run-scoped, optimized for recovery and compaction.</p>
      <ul class="mt-4 compact-list">
        <li>Primary path: <code>.cache/context/run/[run_id]/...</code></li>
        <li>Store oversized logs, stack traces, and artifacts by pointer.</li>
        <li>Keep prompt prefix stable; move volatility into the dynamic tail.</li>
        <li>Append-only records make recovery auditable.</li>
      </ul>
    </div>

    <div class="panel p-6">
      <div class="mini-title">Durable worker memory</div>
      <p class="muted mt-2">Project-local knowledge that should survive beyond one run.</p>
      <ul class="mt-4 compact-list">
        <li>Primary root: <code>.agenthubmemory/</code></li>
        <li><code>TODO.md</code> tracks local execution state.</li>
        <li><code>journal/</code> captures chronological work logs.</li>
        <li><code>note/</code> stores reusable heuristics and lessons.</li>
      </ul>
    </div>
  </div>

  <div class="panel panel-strong p-5 mt-6">
    <div class="mini-title">Design rule</div>
    <p class="mt-2">
      Cross-member sharing goes through mailbox or channel pointers, not direct filesystem writes.
      That keeps ownership explicit and avoids silent context corruption.
    </p>
  </div>
</div>

---

<div class="slide-shell">
  <div class="aurora" style="opacity: 0.56"></div>
  <div class="eyebrow">Skills</div>
  <h1 class="!mt-3 !mb-6">Skills are runtime contracts, not prompt decoration</h1>

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
        Loaded only when the phase needs them, so context size stays controlled.
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
        Domain skills inject concrete workflows, validation rules, and artifact expectations.
      </p>
    </div>
  </div>

  <blockquote class="mt-6">
    The design goal is precision without prompt bloat: role baseline first, phase second, domain
    specialization only when needed.
  </blockquote>
</div>

---

<div class="slide-shell">
  <div class="aurora" style="opacity: 0.6"></div>
  <div class="eyebrow">TiDB</div>
  <h1 class="!mt-3 !mb-6">The TiDB skill pack turns generic agents into database engineers</h1>

  <div class="table-lite panel p-4">
    <table>
      <thead>
        <tr>
          <th>Skill</th>
          <th>What it enforces</th>
          <th>Typical output</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td><code>tidb-optimizer-bugfix</code></td>
          <td>Minimal diff, hypothesis-driven debugging, regression-first validation</td>
          <td>Targeted planner fix plus reusable debugging notes</td>
        </tr>
        <tr>
          <td><code>tidb-doc-finder</code></td>
          <td>Use repo <code>llms.txt</code> as the source-of-truth doc router</td>
          <td>Doc-grounded answers with exact source selection</td>
        </tr>
        <tr>
          <td><code>tidb-profiler-analyzer</code></td>
          <td>Standardize profiler ingestion and top-path analysis</td>
          <td>Actionable CPU or heap summary from zipped artifacts</td>
        </tr>
      </tbody>
    </table>
  </div>

  <div class="grid grid-cols-2 gap-5 mt-6">
    <div class="panel p-5">
      <div class="mini-title">Why this matters</div>
      <ul class="mt-3 compact-list">
        <li>The same runtime can switch from planning to doc lookup to optimizer repair.</li>
        <li>Validation expectations are encoded into the skill, not re-taught every run.</li>
      </ul>
    </div>
    <div class="panel p-5">
      <div class="mini-title">Operational effect</div>
      <ul class="mt-3 compact-list">
        <li>Higher signal-to-token ratio.</li>
        <li>Lower risk of generic, low-quality coding behavior.</li>
      </ul>
    </div>
  </div>
</div>

---

<div class="slide-shell">
  <div class="aurora" style="opacity: 0.58"></div>
  <div class="eyebrow">Example</div>
  <h1 class="!mt-3 !mb-6">An end-to-end TiDB engineering loop</h1>

  <div class="grid grid-cols-[0.95fr_1.05fr] gap-6">
    <div class="panel p-5">
      <div class="mini-title">Execution path</div>
      <ol class="mt-3 pl-5">
        <li>Human asks for an optimizer bug fix.</li>
        <li>Leader decomposes work and creates a task.</li>
        <li>Worker picks the task with <code>tidb-optimizer-bugfix</code>.</li>
        <li>Worker records findings in <code>.agenthubmemory</code>.</li>
        <li>Worker reports evidence back through actor mailbox.</li>
        <li>Leader reviews, integrates, and closes the task.</li>
      </ol>
    </div>

    <div class="panel code-card p-5">
      <div class="mini-title mb-3">What the worker is expected to return</div>
      <ul class="compact-list">
        <li><code>status</code>: usually move the task toward <code>in_review</code>.</li>
        <li><code>result</code>: a compact description of what changed or was proven.</li>
        <li><code>evidence</code>: files, tests, notes, or reproduction artifacts.</li>
        <li><code>next_action</code>: what the leader or reviewer should do next.</li>
      </ul>
      <p class="muted mt-4">
        The point is not pretty JSON. The point is deterministic handoff with enough evidence to review.
      </p>
    </div>
  </div>

  <div class="panel panel-strong p-5 mt-6">
    <div class="mini-title">Core insight</div>
    <p class="mt-2">
      Team, skills, and memory are not separate features. They are the minimum set needed to make
      complex repository work reliable over many turns.
    </p>
  </div>
</div>

---

<div class="slide-shell">
  <div class="aurora" style="opacity: 0.62"></div>
  <div class="eyebrow">Shiro</div>
  <h1 class="!mt-3 !mb-6">Shiro is an optimizer-focused fuzzing system for TiDB</h1>

  <div class="grid grid-cols-4 gap-4">
    <div class="panel p-5">
      <div class="mini-title">Generator</div>
      <p class="muted mt-2">Random schema, data, and SQL with weighted feature toggles.</p>
    </div>
    <div class="panel p-5">
      <div class="mini-title">Oracles</div>
      <p class="muted mt-2">NoREC, TLP, DQP, CERT, CODDTest, DQE, plus GroundTruth-oriented paths.</p>
    </div>
    <div class="panel p-5">
      <div class="mini-title">Guidance</div>
      <p class="muted mt-2">QPG for plan diversity, TQS ideas for join truth and guided exploration.</p>
    </div>
    <div class="panel p-5">
      <div class="mini-title">Artifacts</div>
      <p class="muted mt-2">PLAN REPLAYER dump, minimized repro, case reports, and publishable manifests.</p>
    </div>
  </div>

  <div class="panel code-card p-5 mt-6">
    <div class="mini-title mb-3">The loop starts simply</div>
    <p class="mt-1">
      Launch with <code>go run ./cmd/shiro -config config.yaml</code>, then let generation,
      oracle checks, replay capture, and reporting keep feeding the loop.
    </p>
    <p class="muted mt-4">
      But the interesting part is not the command. It is the closed loop from generation to oracle
      checking to replayable evidence.
    </p>
  </div>
</div>

---

<div class="slide-shell">
  <div class="aurora" style="opacity: 0.58"></div>
  <div class="eyebrow">Guidance</div>
  <h1 class="!mt-3 !mb-6">Shiro pushes beyond random SQL with coverage and truth models</h1>

  <div class="grid grid-cols-3 gap-5">
    <div class="panel p-5">
      <div class="mini-title">QPG</div>
      <p class="muted mt-2">
        Query Plan Guidance uses EXPLAIN plan signatures as a coverage signal.
      </p>
      <ul class="mt-3 compact-list">
        <li>Track repeated shapes and operator sequences.</li>
        <li>Boost joins, aggregates, and subqueries when coverage stalls.</li>
        <li>Coverage driver, not correctness oracle.</li>
      </ul>
    </div>
    <div class="panel p-5">
      <div class="mini-title">TQS ideas</div>
      <p class="muted mt-2">
        Join testing needs data-guided schemas, computable truth, and guided exploration.
      </p>
      <ul class="mt-3 compact-list">
        <li>DSG-style schema generation raises join complexity.</li>
        <li>GroundTruth checks join correctness.</li>
        <li>KQE-style guidance biases under-covered join paths.</li>
      </ul>
    </div>
    <div class="panel p-5">
      <div class="mini-title">Exact multiplicity path</div>
      <p class="muted mt-2">
        Bitmap truth is cheap but undercounts on non-unique join keys. Shiro adds a hash-join
        counting path with caps to stay precise without blowing up memory.
      </p>
    </div>
  </div>

  <div class="panel panel-strong p-5 mt-6">
    <div class="mini-title">Practical result</div>
    <p class="mt-2">
      Shiro moves fuzzing from input diversity to plan diversity plus join truth, which is much
      closer to how optimizer bugs actually hide.
    </p>
  </div>
</div>

---

<div class="slide-shell">
  <div class="aurora" style="opacity: 0.58"></div>
  <div class="eyebrow">AI Triage</div>
  <h1 class="!mt-3 !mb-6">Shiro also grows a metadata and AI-assisted triage plane</h1>

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
      <div class="mini-title">Metadata plane</div>
      <p class="muted mt-2">
        Cloudflare Worker keeps lightweight metadata in D1 while artifacts remain in object storage.
      </p>
    </div>
    <div class="panel p-5">
      <div class="mini-title">AI angle</div>
      <p class="muted mt-2">
        Similar-bug search can add AI explanation and rerank over top candidates, turning raw fuzz
        output into faster human triage.
      </p>
    </div>
  </div>
</div>

---

<div class="slide-shell">
  <div class="aurora"></div>
  <div class="eyebrow">Takeaways</div>
  <h1 class="!mt-3 !mb-8">What this stack teaches</h1>

  <div class="grid grid-cols-2 gap-5">
    <div class="panel p-6">
      <div class="mini-title">1. Coordination needs protocol</div>
      <p class="muted mt-2">
        Team behavior becomes reliable only when message transport, ownership, and replay are explicit.
      </p>
    </div>
    <div class="panel p-6">
      <div class="mini-title">2. Specialization needs skills</div>
      <p class="muted mt-2">
        Reusable skill contracts are a better scaling unit than ever-larger system prompts.
      </p>
    </div>
    <div class="panel p-6">
      <div class="mini-title">3. Long tasks need memory design</div>
      <p class="muted mt-2">
        Stable prefix, append-only logs, and pointerized artifacts are what make long runs recoverable.
      </p>
    </div>
    <div class="panel p-6">
      <div class="mini-title">4. Domain impact comes from closed loops</div>
      <p class="muted mt-2">
        Shiro matters because it closes the loop from bug discovery to replay, report, and triage.
      </p>
    </div>
  </div>

  <div class="panel panel-strong p-6 mt-6">
    <div class="text-3xl font-semibold leading-tight">
      The real product is not "an agent". It is the engineering system that lets many agents,
      tools, and artifacts compound over time.
    </div>
  </div>
</div>

# WardrikResearch

Deep research for agents: a topic is split across angles, a subagent researches each at once, and
one more brings what they found into one report.

```elixir
def deps do
  [
    {:wardrik_research, "~> 0.1"}
  ]
end
```

Give an agent the capability beside a search tool, and it calls it as `deep_research`:

```elixir
WardrikCore.start_agent(
  agent_id: "acme/analyst",
  model: "anthropic:claude-haiku-4-5",
  capabilities: [{WardrikBrave, brave: MyApp.Brave}, WardrikResearch]
)
```

Each researcher runs as a subagent of the agent that called it, through `WardrikCore.subagent/3`:
on its model, middleware and tools, but `deep_research`, so research reaches what the agent can and
a researcher can't start a sweep of its own. Without a search tool, research is limited to what the
model knows. What the researchers spend counts as the call's, so the agent's budgets hold them, and
what they read labels its answer, as reading it would. A call that would wait on a person ends that
researcher's angle instead.

In a [Wardrik](https://hexdocs.pm/wardrik), offer it by name, and a definition names it in its
`tools`:

```elixir
config :my_app, MyApp.Wardrik,
  capabilities: [web_search: {WardrikBrave, brave: MyApp.Brave}, deep_research: WardrikResearch]
```

The daemon offers it as `deep_research`.

Choose the angles for your deployment, each with what sets it apart, added to the researcher's
instructions:

```elixir
{WardrikResearch,
 angles: [
   %{angle: "pricing and packaging", prompt: "Think like a pricing analyst."},
   %{angle: "recent developments"}
 ]}
```

A caller may name its own angles for one topic. It also takes `:max_concurrency`, how many run at
once, 5 unless set, `:timeout`, how long one may take, 8 minutes unless set, and `:max_rounds`, the
model calls each may make, 12 unless set.

The tool answers the `topic`, the `report`, and the `gaps`: each angle that failed or ran out of
time, and why. The rest are still brought together. Only a sweep where every angle failed is an
error. Each researcher appears in the agent's events as `wardrik.subagent.started`, then
`wardrik.subagent.completed` or `wardrik.subagent.failed`.

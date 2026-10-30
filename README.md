# WardrikResearch

Deep research for agents. It splits a topic into angles, researches each one in its own subagent at
the same time, and combines the findings into one report.

```elixir
def deps do
  [
    {:wardrik_research, "~> 0.1.0-rc.1"}
  ]
end
```

## Usage

Give an agent `WardrikResearch` next to a search tool. The agent calls it as `deep_research`:

```elixir
WardrikCore.start_agent(
  agent_id: "acme/analyst",
  model: "anthropic:claude-haiku-4-5",
  capabilities: [{WardrikBrave, brave: MyApp.Brave}, WardrikResearch]
)
```

In [Wardrik](https://hexdocs.pm/wardrik), offer it by name. A definition then lists that name in
its `tools`:

```elixir
config :my_app, MyApp.Wardrik,
  capabilities: [web_search: {WardrikBrave, brave: MyApp.Brave}, deep_research: WardrikResearch]
```

The daemon offers it as `deep_research`.

## Options

```elixir
{WardrikResearch,
 angles: [
   %{angle: "pricing and packaging", prompt: "Think like a pricing analyst."},
   %{angle: "recent developments"}
 ],
 max_concurrency: 3}
```

  * `:angles` - the angles a topic is split into, each `%{angle: name}` with an optional `:prompt`
    added to that researcher's instructions. Five general angles unless set.
  * `:max_concurrency` - how many researchers run at once. `5` unless set.
  * `:timeout` - how long one researcher may take, in milliseconds. 8 minutes unless set.
  * `:max_rounds` - how many model calls one researcher may make. `12` unless set.

The agent may also pass its own `angles` for a single call.

## How it runs

Each researcher is a subagent of the calling agent, made with `WardrikCore.subagent/3`:

  * It runs on the agent's model, middleware and tools, except `deep_research`. A researcher can't
    start research of its own.
  * Without a search tool, it only knows what the model knows.
  * What it spends counts toward the agent's budgets.
  * What it reads labels the answer, as if the agent had read it.
  * A call that would wait for a person ends that researcher's angle.

## Result

The tool returns a map:

```elixir
%{
  "topic" => "AI code review tools",
  "report" => "...",
  "gaps" => [%{"angle" => "where this appears to be heading", "reason" => "it ran out of time"}]
}
```

A failed or timed-out angle is listed in `"gaps"`, and the rest are still combined. The call is an
error only when every angle fails.

Each researcher shows up in the agent's events as `wardrik.subagent.started`, then
`wardrik.subagent.completed` or `wardrik.subagent.failed`.

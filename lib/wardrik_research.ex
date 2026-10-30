defmodule WardrikResearch do
  @moduledoc """
  Deep research for agents, as the `deep_research` tool.

  It splits a topic into angles, researches each one in its own subagent at the same time, and
  combines the findings into one report.

      WardrikCore.start_agent(
        agent_id: "acme/analyst",
        model: "anthropic:claude-haiku-4-5",
        capabilities: [{WardrikBrave, brave: MyApp.Brave}, WardrikResearch]
      )

  Each researcher runs on the agent's model, middleware and tools, except `deep_research`. Give
  the agent a search tool, or research only knows what the model knows. What researchers spend
  counts toward the agent's budgets, and what they read labels the answer.

  ## Options

      {WardrikResearch, angles: [%{angle: "pricing", prompt: "Think like a pricing analyst."}]}

    * `:angles` - the angles a topic is split into, each `%{angle: name}` with an optional
      `:prompt` added to that researcher's instructions. Five general angles unless set.
    * `:max_concurrency` - how many researchers run at once. `5` unless set.
    * `:timeout` - how long one researcher may take, in milliseconds. 8 minutes unless set.
    * `:max_rounds` - how many model calls one researcher may make. `12` unless set.

  The agent may pass its own angles for a single call. A failed or timed-out angle is reported as
  a gap, and the rest are still combined. The call is an error only when every angle fails.
  """

  @behaviour WardrikCore.Capability

  @impl WardrikCore.Capability
  def tools(_context, opts), do: [WardrikResearch.Deep.tool(opts)]
end

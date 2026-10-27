defmodule WardrikResearch do
  @moduledoc """
  Deep research for agents: a topic is split across angles, a subagent researches each at once,
  and one more brings what they found into one report. The agent calls it as `deep_research`:

      WardrikCore.start_agent(
        agent_id: "acme/analyst",
        model: "anthropic:claude-haiku-4-5",
        capabilities: [{WardrikBrave, brave: MyApp.Brave}, WardrikResearch]
      )

  Its researchers run as subagents of the agent that called it, on its model, middleware and tools
  but this one, so what research can reach is what the agent can, and a researcher can't start a
  sweep of its own. Give the agent a search tool, or research is limited to what the model knows.
  What they spend counts as the call's, and what they read labels its answer, as reading it would.

  It takes `:angles`, the deployment's own, each `%{angle: name}` and, if you like, the `:prompt`
  that sets it apart, added to the researcher's; `:max_concurrency`, how many run at once, 5 unless
  set; `:timeout`, how long one may take, 8 minutes unless set; and `:max_rounds`, the model calls
  each may make, 12 unless set. A caller may name its own angles, plainly, for one topic.

  An angle that fails or runs out of time is a gap, and the rest are still brought together. Only a
  sweep where every angle failed is an error.
  """

  @behaviour WardrikCore.Capability

  @impl WardrikCore.Capability
  def tools(_context, opts), do: [WardrikResearch.Deep.tool(opts)]
end

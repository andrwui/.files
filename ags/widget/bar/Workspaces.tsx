import { createBinding, For } from 'ags'
import AstalHyprland from 'gi://AstalHyprland?version=0.1'
import sortWorkspaces from '../../helper/workspaces'

export default function Workspaces() {
  const hypr = AstalHyprland.get_default()

  const workspaces = createBinding(hypr, 'workspaces').as((wps) => sortWorkspaces(wps))
  const activeWorkspace = createBinding(hypr, 'focused_workspace')

  return (
    <box
      class="container workspaces"
      spacing={5}
    >
      <For each={workspaces}>
        {(wp) => {
          return (
            <box
              class="workspace"
              css={activeWorkspace.as((awp) =>
                wp.id === awp.id ? 'background: white; min-width: 35px;' : 'background: #1a1a1a',
              )}
            />
          )
        }}
      </For>
    </box>
  )
}

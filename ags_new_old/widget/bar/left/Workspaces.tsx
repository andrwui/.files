import AstalHyprland from 'gi://AstalHyprland?version=0.1'
import { Gtk } from 'astal/gtk3'
import { bind, execAsync } from 'astal'

export default function Workspaces() {
  const hypr = AstalHyprland.get_default()

  return (
    <box
      className="container workspaces"
      spacing={5}
      halign={Gtk.Align.START}
    >
      {bind(hypr, 'workspaces').as((workspaces) => {
        return workspaces
          .sort((a, b) => a.id - b.id)
          .map((workspace) => {
            return (
              <eventbox
                cursor={'pointer'}
                onClick={() => execAsync(`hyprctl dispatch workspace ${workspace.id}`)}
              >
                <box
                  className={'workspace'}
                  css={bind(hypr, 'focusedWorkspace').as(
                    (fw) =>
                      `${fw.id === workspace.id ? 'background: white; min-width: 35px;' : 'background: #6a6a6a'};`,
                  )}
                />
              </eventbox>
            )
          })
      })}
    </box>
  )
}

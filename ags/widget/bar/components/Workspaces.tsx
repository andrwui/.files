import { bind, execAsync } from 'astal'
import Hyprland from 'gi://AstalHyprland?version=0.1'

const Workspaces = () => {
  const hypr = Hyprland.get_default()

  return (
    <box spacing={5}>
      {bind(hypr, 'workspaces').as((workspaces) => {
        return workspaces
          .sort((a, b) => a.id - b.id)
          .map((workspace) => {
            return (
              <eventbox
                cursor={'pointer'}
                onClick={() => execAsync(`hyprctl dispatch workspace ${workspace.id}`)}
                widthRequest={20}
              >
                <box
                  css={bind(hypr, 'focusedWorkspace').as((fw) =>
                    fw.id === workspace.id ? 'background: white;' : 'background: #171717',
                  )}
                />
              </eventbox>
            )
          })
      })}
    </box>
  )
}

export default Workspaces

import { bind } from 'astal'
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
              <box
                widthRequest={18}
                css={bind(hypr, 'focusedWorkspace').as((fw) =>
                  fw.id === workspace.id
                    ? 'background-color: #FFFFFF'
                    : 'background-color: #1a1a1a',
                )}
              ></box>
            )
          })
      })}
    </box>
  )
}

export default Workspaces

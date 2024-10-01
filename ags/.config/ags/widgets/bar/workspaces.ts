import { hyprland } from "../../util/services"


const Workspaces = () => {
  const activeID = hyprland.active.workspace.bind("id")

  const workspaces = hyprland.bind("workspaces").as(ws => {
    const sortedWS = ws.sort((a, b) => a.id - b.id)

    return sortedWS.map((workspace) => Widget.Box({
	width_request: 20,
	height_request: 20,
	className: activeID.as(i => {
	return `workspace ${i === workspace.id ? "selected" : ''}`}
        
      ),
    }))
  })

  return Widget.Box({
    className: 'workspaces',
    children: workspaces
  })
}

export default Workspaces

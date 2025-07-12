import AstalHyprland from "gi://AstalHyprland?version=0.1"
export default function sortWorkspaces(wps: AstalHyprland.Workspace[]) {
  return wps.sort((a, b) => a.id - b.id)
}

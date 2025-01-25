import Hyprland from 'gi://AstalHyprland?version=0.1'

export const groupHyprlandWorkspaces = (array: Hyprland.Workspace[]): Hyprland.Workspace[][] => {
  const map = new Map<Hyprland.Monitor, Hyprland.Workspace[]>()

  array.forEach((item) => {
    const key = item.monitor
    if (key === null) {
      return
    }
    if (!map.has(key)) {
      map.set(key, [])
    }
    map.get(key)!.unshift(item)
  })

  return Array.from(map.values()).sort((a, b) => {
    return a[0].monitor.id - b[0].monitor.id
  })
}

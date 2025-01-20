import { App } from 'astal/gtk3'

export const closeAllOtherWindows = (windowName: string) => {
  App.get_windows().forEach((window) => {
    if (window.name.includes('bar')) return
    if (window.name === windowName) return
    if (windowName !== '') App.toggle_window(window.name)
    window.hide()
  })

  App.toggle_window(windowName)
}

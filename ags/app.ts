import app from 'ags/gtk3/app'
import style from './style.scss'
import Bar from './widget/bar/Bar'
import Tray from './widget/tray/Tray'
import DynamicBar, { DynamicBarState } from './widget/dynamic-bar/DynamicBar'
import DynamicBarStateContext from './singleton/dynamic-bar-state-context'
import LauncherStateContext from './singleton/app-launcher-state'
import Launcher from './widget/dynamic-bar/Launcher'

app.start({
  requestHandler: (req, res) => {
    const barStateInstance = DynamicBarStateContext.getInstance()
    const launcherState = LauncherStateContext.getInstance()

    if (req === 'app_launcher') {
      launcherState.set(true)
    }
    if (req === 'widgets') {
      barStateInstance.set(DynamicBarState.WIDGETS)
    }

    res(barStateInstance.get().get())
  },
  css: style,
  main() {
    app
      .get_monitors()
      .sort((a, b) => (a.model === '0x08C7' ? 1 : b.model === '0x08C7' ? -1 : 0))
      .map((monitor) => {
        const singleMonitor = app.get_monitors().length === 1
        const { x, y } = monitor.geometry
        const isPrimary = singleMonitor ? true : x === 0 && y === 0
        return [Bar(monitor), Tray(monitor), DynamicBar(monitor, isPrimary), Launcher(monitor)]
      })
  },
})
/*  
    App.get_monitors().map((monitor) => {
      const { x, y } = monitor.geometry
      const isPrimary = singleMonitor ? true : x === 0 && y === 0
      return [Bar(monitor, isPrimary), ActionBar(monitor, isPrimary), Lock(monitor, isPrimary)]
*  */

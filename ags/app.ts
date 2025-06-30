import { App } from 'astal/gtk3'
import style from './style.scss'
import Bar from '@/widget/bar/Bar'
import Notch from '@/widget/notch/Notch'
import Lock from './widget/lock/Lock'
import LockScreenState from './singleton/lockScreenState/LockScreenState'
import { GLib } from 'astal'

export enum AppRequests {
  LOCK_SCREEN = 'lock',
}

const lockScreenState = LockScreenState.getInstance()

App.start({
  css: style,
  icons: `${GLib.getenv('HOME')}/.files/ags/icons/`,

  requestHandler: (req) => {
    if (req === AppRequests.LOCK_SCREEN) {
      lockScreenState.set(true)
    }
  },

  main() {
    const singleMonitor = App.get_monitors().length === 1
    App.get_monitors().map((monitor) => {
      const { x, y } = monitor.geometry
      const isPrimary = singleMonitor ? true : x === 0 && y === 0
      return [Bar(monitor, isPrimary), Notch(monitor, isPrimary), Lock(monitor, isPrimary)]
    })
  },
})

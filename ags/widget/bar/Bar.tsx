import { App, Astal, Gdk, Gtk } from 'astal/gtk3'
import Battery from './components/Battery'
import Clock from './components/Clock'
import QuickAccess from './components/QuickAccess'
import Workspaces from './components/Workspaces'
import SystemTray from './components/SystemTray'
import Bluetooth from './components/Bluetooth'
import Sound from './components/Sound'
import PowerMenu from './components/PowerMenu'
import Network from './components/Network'

const Bar = (monitor: Gdk.Monitor, monitorIndex: number) => {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

  return (
    <window
      className="Bar"
      name="bar"
      gdkmonitor={monitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      layer={Astal.Layer.TOP}
      anchor={TOP | LEFT | RIGHT}
      application={App}
    >
      <centerbox>
        <QuickAccess monitorIndex={monitorIndex} />
        <Workspaces />
        <box
          halign={Gtk.Align.END}
          spacing={10}
        >
          <Bluetooth monitorIndex={monitorIndex} />
          <Sound monitorIndex={monitorIndex} />
          <Network monitorIndex={monitorIndex} />
          <box widthRequest={15} />
          <Battery />
          <Clock monitorIndex={monitorIndex} />
          <SystemTray monitorIndex={monitorIndex} />
          <PowerMenu monitorIndex={monitorIndex} />
        </box>
      </centerbox>
    </window>
  )
}

export default Bar

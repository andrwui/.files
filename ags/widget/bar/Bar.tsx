import { App, Astal, Gdk, Gtk } from 'astal/gtk3'
import Battery from './bar_items/Battery'
import Clock from './bar_items/Clock'
import QuickAccess from './bar_items/QuickAccess'
import Workspaces from './bar_items/Workspaces'
import SystemTray from './bar_items/SystemTray'
import Bluetooth from './bar_items/Bluetooth'
import Sound from './bar_items/Sound'
import PowerMenu from './bar_items/PowerMenu'
import Network from './bar_items/Network'
import Hyprsources from './bar_items/Hyprsources'

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
          <Hyprsources monitorIndex={monitorIndex} />
          <Bluetooth monitorIndex={monitorIndex} />
          <Sound monitorIndex={monitorIndex} />
          <Network monitorIndex={monitorIndex} />
          <box widthRequest={15} />
          <Battery />
          <box widthRequest={15} />
          <Clock monitorIndex={monitorIndex} />
          <SystemTray monitorIndex={monitorIndex} />
          <PowerMenu monitorIndex={monitorIndex} />
        </box>
      </centerbox>
    </window>
  )
}

export default Bar

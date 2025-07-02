import { App, Astal, Gdk, Gtk } from 'astal/gtk3'
import Workspaces from './left/Workspaces'
import Battery from './right/Battery'

const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

export default function Bar(gdkmonitor: Gdk.Monitor, isPrimary: boolean) {
  return (
    <window
      className="Bar"
      gdkmonitor={gdkmonitor}
      anchor={TOP | LEFT | RIGHT}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      layer={Astal.Layer.TOP}
      application={App}
      heightRequest={35}
      visible={true}
    >
      <box
        margin_left={5}
        margin_right={5}
      >
        <box margin_top={5}>
          <Workspaces />
        </box>
        <box
          className={'top_bar'}
          hexpand
          halign={Gtk.Align.CENTER}
          width_request={300}
          opacity={0}
          vertical
        >
          <box></box>
        </box>
        <box
          spacing={10}
          margin_top={5}
        >
          <Battery />
        </box>
      </box>
    </window>
  )
}

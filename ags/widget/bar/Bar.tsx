import Astal from 'gi://Astal?version=3.0'
import Workspaces from './Workspaces'
import Gdk from 'gi://Gdk?version=3.0'

const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

export default function Bar(gdkmonitor: Gdk.Monitor) {
  return (
    <window
      class="Bar"
      gdkmonitor={gdkmonitor}
      anchor={TOP | LEFT | RIGHT}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      layer={Astal.Layer.TOP}
      heightRequest={35}
      visible={true}
    >
      <box
        margin_left={5}
        margin_right={5}
        margin_top={5}
        hexpand
      >
        <Workspaces />
      </box>
    </window>
  )
}

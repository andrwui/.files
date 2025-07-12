import { Gtk } from 'astal/gtk3'
import LayoutContainer from '../LayoutContainer'
import UsagePanel from './usage/UsagePanel'
import BluetoothCard from './conectivity/BluetoothCard'
import WifiCard from './conectivity/WifiCard'
import { WidgetPanelLayoutType } from '@/singleton/widget_panel_layout/WidgetPanelLayout'

export default function HomeLayout() {
  return (
    <LayoutContainer
      name={WidgetPanelLayoutType.HOME}
      className="homeLayout"
      spacing={20}
    >
      {/*Left box*/}
      <box
        vertical
        halign={Gtk.Align.FILL}
      >
        <UsagePanel />
        <box spacing={-41}>
          <slider
            className="slider"
            css="border-radius: 10px;"
            vertical
            vexpand
            inverted
          />
          <icon
            valign={Gtk.Align.END}
            icon="i-sound"
            css="font-size: 2em;padding-bottom:1em;"
          />
        </box>
      </box>

      {/*Right box*/}
      <box
        hexpand
        halign={Gtk.Align.FILL}
        vertical
      >
        <box
          spacing={5}
          homogeneous
        >
          <BluetoothCard />
          <WifiCard />
        </box>
      </box>
    </LayoutContainer>
  )
}

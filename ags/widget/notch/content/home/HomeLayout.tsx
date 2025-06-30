import { Gtk } from 'astal/gtk3'
import LayoutContainer from '../LayoutContainer'
import UsagePanel from './usage/UsagePanel'
import BluetoothCard from './conectivity/BluetoothCard'
import WifiCard from './conectivity/WifiCard'
import { NotchLayoutType } from '@/singleton/notchLayout/NotchLayout'

export default function HomeLayout() {
  return (
    <LayoutContainer
      name={NotchLayoutType.HOME}
      className="homeLayout"
      spacing={20}
    >
      {/*Left box*/}
      <box
        vertical
        halign={Gtk.Align.FILL}
      >
        <UsagePanel />
      </box>

      {/*Right box*/}
      <box
        hexpand
        halign={Gtk.Align.FILL}
        vertical
      >
        <box spacing={5}>
          <BluetoothCard />
          <WifiCard />
        </box>
      </box>
    </LayoutContainer>
  )
}

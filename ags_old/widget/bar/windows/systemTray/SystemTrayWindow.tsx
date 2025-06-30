import { Gdk } from 'astal/gtk3'
import AstalTray from 'gi://AstalTray?version=0.1'
import { chunk } from '../../../../helper/helper'
import TrayItem from './TrayItem'
import GenericWindow from '../_generic/GenericWindow'

export const SystemTrayWindowNamePrefix = 'systemTray'

const SystemTrayWindow = (monitor: Gdk.Monitor, monitorIndex: number) => {
  const windowName = `${SystemTrayWindowNamePrefix}-${monitorIndex}`

  const tray = AstalTray.get_default()
  const items = tray.get_items()
  console.log(items)
  console.log(items)
  console.log(items)
  console.log(items)

  return (
    <GenericWindow
      gdkmonitor={monitor}
      name={windowName}
    >
      <box
        spacing={10}
        vertical
      >
        {chunk(items, 4).map((chunk) => {
          return (
            <box spacing={7}>
              {chunk.map((item) => {
                const menu = item.create_menu()
                return (
                  <TrayItem
                    menu={menu}
                    item={item}
                  />
                )
              })}
            </box>
          )
        })}
      </box>
      <></>
    </GenericWindow>
  )
}
export default SystemTrayWindow

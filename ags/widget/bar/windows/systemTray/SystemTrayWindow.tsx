import { App, Astal, Gdk } from 'astal/gtk3'
import AstalTray from 'gi://AstalTray?version=0.1'
import { bind } from 'astal'
import { chunk } from '../../../../helper/helper'
import TrayItem from './TrayItem'

export const SystemTrayWindowNamePrefix = 'systemTray'

const SystemTrayWindow = (monitor: Gdk.Monitor, monitorIndex: number) => {
  const windowName = `${SystemTrayWindowNamePrefix}-${monitorIndex}`

  const tray = AstalTray.get_default()
  const { RIGHT, TOP } = Astal.WindowAnchor

  return (
    <window
      gdkmonitor={monitor}
      name={windowName}
      anchor={TOP | RIGHT}
      margin={15}
      visible={false}
      application={App}
    >
      <box
        spacing={10}
        className={'window'}
        vertical
      >
        {bind(tray, 'items').as((items) => {
          return chunk(items, 4).map((chunk) => {
            return (
              <box spacing={10}>
                {chunk.map((item) => {
                  const menu = item.create_menu()
                  return (
                    <TrayItem
                      item={item}
                      menu={menu}
                    />
                  )
                })}
              </box>
            )
          })
        })}
      </box>
    </window>
  )
}
export default SystemTrayWindow

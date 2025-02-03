import { closeAllOtherWindows } from './helper'
import { SystemTrayWindowNamePrefix } from '../windows/systemTray/SystemTrayWindow'
import { bind } from 'astal'
import AstalTray from 'gi://AstalTray'

const SystemTray = ({ monitorIndex }: { monitorIndex: number }) => {
  const windowName = `${SystemTrayWindowNamePrefix}-${monitorIndex}`

  const tray = AstalTray.get_default()

  return (
    <box>
      {bind(tray, 'items').as((items) => {
        return items.length > 0 ? (
          <eventbox
            cursor={'pointer'}
            onClick={() => closeAllOtherWindows(windowName)}
          >
            <label
              widthRequest={15}
              css={``}
              label={'󰅀'}
            />
          </eventbox>
        ) : (
          ''
        )
      })}
    </box>
  )
}

export default SystemTray

import { closeAllOtherWindows } from './helper'
import { SystemTrayWindowNamePrefix } from '../windows/systemTray/SystemTrayWindow'

const SystemTray = ({ monitorIndex }: { monitorIndex: number }) => {
  const windowName = `${SystemTrayWindowNamePrefix}-${monitorIndex}`

  return (
    <eventbox
      widthRequest={20}
      css="font-weight: 100; font-size: 15px;"
      onClick={() => closeAllOtherWindows(windowName)}
    >
      
    </eventbox>
  )
}

export default SystemTray

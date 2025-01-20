import { PowerMenuWindowNamePrefix } from '../windows/powerMenu/PowerMenuWindow'
import { closeAllOtherWindows } from './helper'

const PowerMenu = ({ monitorIndex }: { monitorIndex: number }) => {
  const windowName = `${PowerMenuWindowNamePrefix}-${monitorIndex}`

  return (
    <eventbox
      width_request={20}
      css="font-weight: 100; font-size: 15px;"
      onClick={() => closeAllOtherWindows(windowName)}
    >
      󰐥
    </eventbox>
  )
}

export default PowerMenu

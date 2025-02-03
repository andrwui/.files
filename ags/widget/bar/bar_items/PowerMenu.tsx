import { PowerMenuWindowNamePrefix } from '../windows/powerMenu/PowerMenuWindow'
import { closeAllOtherWindows } from './helper'

const PowerMenu = ({ monitorIndex }: { monitorIndex: number }) => {
  const windowName = `${PowerMenuWindowNamePrefix}-${monitorIndex}`

  return (
    <eventbox
      cursor={'pointer'}
      css={`
        font-weight: 100;
        font-size: 13px;
      `}
      onClick={() => closeAllOtherWindows(windowName)}
    >
      󰐥
    </eventbox>
  )
}

export default PowerMenu

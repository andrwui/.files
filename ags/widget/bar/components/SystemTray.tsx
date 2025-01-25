import { closeAllOtherWindows } from './helper'
import { SystemTrayWindowNamePrefix } from '../windows/systemTray/SystemTrayWindow'

const SystemTray = ({ monitorIndex }: { monitorIndex: number }) => {
  const windowName = `${SystemTrayWindowNamePrefix}-${monitorIndex}`

  return (
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
  )
}

export default SystemTray

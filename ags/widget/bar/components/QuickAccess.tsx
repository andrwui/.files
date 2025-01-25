import { execAsync } from 'astal'
import { isPrimaryClick } from '../windows/helper'
import { ScreenshotWindowNamePrefix } from '../windows/screenshot/ScreenshotWindow'
import { closeAllOtherWindows } from './helper'

const QuickAccess = ({ monitorIndex }: { monitorIndex: number }) => {
  const colorPickerCmd = 'hyprpicker -a -f hex -r'
  const screenshotCmd = 'hyprshot -m region'
  const windowName = `${ScreenshotWindowNamePrefix}-${monitorIndex}`

  const cpButton = (
    <eventbox
      widthRequest={18}
      onClick={async () => await execAsync(colorPickerCmd)}
      cursor={'pointer'}
    >
      󰈊
    </eventbox>
  )
  const ssButton = (
    <eventbox
      widthRequest={18}
      onClick={(_, evt) => {
        if (isPrimaryClick(evt)) {
          execAsync(screenshotCmd).catch(console.error)
          return
        }
        closeAllOtherWindows(windowName)
      }}
      cursor={'pointer'}
    >
      󰹑
    </eventbox>
  )

  return (
    <box spacing={5}>
      {cpButton}
      {ssButton}
    </box>
  )
}

export default QuickAccess

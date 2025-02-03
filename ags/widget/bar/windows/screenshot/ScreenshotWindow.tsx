import { closeAllOtherWindows } from '../../bar_items/helper'
import GenericWindow from '../_generic/GenericWindow'
import Separator from '../_generic/Separator'
import { execAsync } from 'astal'
import { Astal, Gdk } from 'astal/gtk3'

export const ScreenshotWindowNamePrefix = 'screenshotWindow'

const ScreenshotWindow = (monitor: Gdk.Monitor, monitorIndex: number) => {
  const regionCmd = 'hyprshot -m region'
  const monitorCmd = 'hyprshot -m output'
  const windowCmd = 'hyprshot -m window'

  const windowName = `${ScreenshotWindowNamePrefix}-${monitorIndex}`

  const { TOP, LEFT } = Astal.WindowAnchor

  return (
    <GenericWindow
      gdkmonitor={monitor}
      name={windowName}
      anchor={TOP | LEFT}
      marginLeft={15}
    >
      <eventbox
        onClick={() => {
          execAsync(regionCmd)
          closeAllOtherWindows('')
        }}
        widthRequest={120}
      >
        region
      </eventbox>
      <Separator />
      <eventbox
        onClick={() => {
          execAsync(monitorCmd)
          closeAllOtherWindows('')
        }}
      >
        monitor
      </eventbox>
      <Separator />
      <eventbox
        onClick={() => {
          execAsync(windowCmd)
          closeAllOtherWindows('')
        }}
      >
        window
      </eventbox>
    </GenericWindow>
  )
}

export default ScreenshotWindow

import { App } from 'astal/gtk3'
import Bar from './widget/bar/Bar'
import { exec } from 'astal'
import BluetoothWindow from './widget/bar/windows/bluetooth/BluetoothWindow'
import SoundWindow from './widget/bar/windows/sound/SoundWindow'
import SystemTrayWindow from './widget/bar/windows/systemTray/SystemTrayWindow'
import PowerMenuWindow from './widget/bar/windows/powerMenu/PowerMenuWindow'
import NetworkWindow from './widget/bar/windows/network/NetworkWindow'
import ScreenshotWindow from './widget/bar/windows/screenshot/ScreenshotWindow'
import CalendarWindow from './widget/bar/windows/calendar/CalendarWindow'

const sassSource = '/home/andrw/.files/ags/style/index.sass'
const cssOutdir = '/tmp/ags/css.css'

const sassCompile = `sass ${sassSource}:${cssOutdir} --no-source-map`

exec(sassCompile)

App.start({
  css: cssOutdir,
  main() {
    App.get_monitors().map((monitor, i) => {
      return [
        Bar(monitor, i),
        BluetoothWindow(monitor, i),
        SoundWindow(monitor, i),
        SystemTrayWindow(monitor, i),
        PowerMenuWindow(monitor, i),
        NetworkWindow(monitor, i),
        ScreenshotWindow(monitor, i),
        CalendarWindow(monitor, i),
      ]
    })
  },
})

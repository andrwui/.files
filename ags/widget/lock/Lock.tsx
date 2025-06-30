import { Durations } from '@/constants/constants'
import LockScreenState from '@/singleton/lockScreenState/LockScreenState'
import { Variable, bind, derive, exec, timeout } from 'astal'
import { Gdk, Gtk } from 'astal/gtk3'
import App from 'astal/gtk3/app'
import Astal from 'gi://Astal?version=3.0'
import GLib from 'gi://GLib?version=2.0'
import LockEntry from './LockEntry'

export const defaultLockMsg = `Welcome, ${GLib.getenv('USER')}`

export default function Lock(monitor: Gdk.Monitor, isPrimary: boolean) {
  const time = Variable<string>('').poll(1000, () => GLib.DateTime.new_now_local().format('%H:%M')!)
  const { TOP, LEFT, RIGHT, BOTTOM } = Astal.WindowAnchor

  const lockScreenState = LockScreenState.getInstance()

  const message = Variable<string>(defaultLockMsg)

  const imgPathRoot = '/tmp/lock_image'
  const imgPath = Variable('')

  const shouldShowWindow = Variable<boolean>(false)
  const shouldShowBackground = Variable<boolean>(false)
  const backgroundState = derive(
    [bind(imgPath), bind(shouldShowBackground)],
    (imgPath, shouldShow) => ({
      imgPath,
      shouldShow,
    }),
  )

  const display = Gdk.Display.get_default()

  function getMonitorName(monitor: Gdk.Monitor) {
    if (display) {
      const screen = display.get_default_screen()
      const displayMonitors = display.get_n_monitors()
      for (let i = 0; i < displayMonitors; i++) {
        if (monitor === display.get_monitor(i)) {
          return screen.get_monitor_plug_name(i)
        }
      }
    }
  }

  lockScreenState.get().subscribe((state) => {
    const monName = getMonitorName(monitor)

    if (monName) {
      if (state) {
        const randomNumber = String(Math.random()).split('.')[1]
        imgPath.set(imgPathRoot + '-' + monName + `-${randomNumber}.jpg`)
        exec([
          'bash',
          '-e',
          `${GLib.getenv('HOME')}/.files/ags/bins/lock_screenshot.sh`,
          monName,
          imgPath.get(),
        ])
        console.log(imgPath)
      } else {
        exec(['rm', `${imgPath.get()}`])
      }
    }
  })

  lockScreenState.get().subscribe((state) => {
    if (state) {
      shouldShowWindow.set(true)
      timeout(Durations.TRANSITION, () => {
        shouldShowBackground.set(true)
      })
    }
    if (!state) {
      shouldShowBackground.set(false)
      timeout(Durations.TRANSITION, () => {
        shouldShowWindow.set(false)
      })
    }
  })

  return (
    <window
      keymode={Astal.Keymode.EXCLUSIVE}
      namespace={'LOCK_SCREEN'}
      visible={shouldShowWindow()}
      name="lock_window"
      className="lock_window"
      anchor={TOP | LEFT | RIGHT | BOTTOM}
      gdkmonitor={monitor}
      application={App}
      exclusivity={Astal.Exclusivity.IGNORE}
      layer={Astal.Layer.OVERLAY}
    >
      <box
        className="background_image"
        hexpand
        vexpand
        visible
        css={backgroundState().as(
          ({ imgPath, shouldShow }) => `
          background-image: url('${imgPath}');
          opacity: ${shouldShow ? '1' : '0'};
        `,
        )}
        canFocus
      >
        <box
          vexpand
          hexpand
          halign={Gtk.Align.FILL}
          valign={Gtk.Align.FILL}
          homogeneous
          className="background_backdrop"
        >
          {isPrimary ? (
            <box
              className="content"
              halign={Gtk.Align.CENTER}
              valign={Gtk.Align.CENTER}
              vexpand={false}
              heightRequest={15}
              vertical
              canFocus
              spacing={30}
            >
              <label
                label={time()}
                className="time"
              />
              <box
                spacing={10}
                width_request={200}
                vertical
              >
                <label
                  label={message()}
                  className="message"
                />
                <LockEntry message={message} />
              </box>
            </box>
          ) : (
            ''
          )}
        </box>
      </box>
    </window>
  )
}

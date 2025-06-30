import { App, Astal, Gtk, Gdk } from 'astal/gtk3'
import NotchState, { NotchStateType } from '@/singleton/notchState/NotchState'

import NotchHead from './head/NotchHead'
import HomeLayout from './content/home/HomeLayout'
import { AstalIO, bind, timeout, Variable } from 'astal'
import { Durations } from '@/constants/constants'
import BluetoothLayout from './content/bluetooth/BluetoothLayout'
import NotchLayout, { NotchLayoutType } from '@/singleton/notchLayout/NotchLayout'
import AstalBluetooth from 'gi://AstalBluetooth?version=0.1'

const { TOP } = Astal.WindowAnchor

export default function Notch(gdkmonitor: Gdk.Monitor, isPrimary: boolean) {
  const notchState = NotchState.getInstance(gdkmonitor)
  const notchLayout = NotchLayout.getInstance()

  const bluetooth = AstalBluetooth.get_default()

  const shouldRevealContent = Variable<boolean>(false)
  const shouldRenderContent = Variable<boolean>(false)

  const spacingVariable = Variable.derive(
    [notchState.get(), bind(shouldRevealContent)],
    (notchState, shouldReveal) => {
      return notchState === NotchStateType.HOVERED && shouldReveal ? 0 : -5000
    },
  )

  let showTimeout = AstalIO.Time.timeout(0, () => {})

  // Subscriber for transitions
  notchState.get().subscribe((state) => {
    if (state === NotchStateType.HOVERED) {
      showTimeout = timeout(Durations.TRANSITION, () => {
        shouldRenderContent.set(true)
        shouldRevealContent.set(true)
      })
    } else {
      showTimeout.cancel()
      shouldRenderContent.set(false)
      timeout(Durations.TRANSITION, () => {
        shouldRevealContent.set(false)
      })
    }
  })

  // Subscriber for other stuff
  notchState.get().subscribe((state) => {
    if (state !== NotchStateType.HOVERED) {
      notchLayout.set(NotchLayoutType.HOME)

      if (bluetooth.adapter.discovering) {
        bluetooth.adapter.stop_discovery()
      }
    }
  })

  notchLayout.get().subscribe((layout) => {
    console.log({ layout })
    if (layout === NotchLayoutType.BLUETOOTH) {
      if (!bluetooth.adapter.discovering) {
        bluetooth.adapter.start_discovery()
      }
    } else {
      if (bluetooth.adapter.discovering) {
        bluetooth.adapter.stop_discovery()
      }
    }
  })

  // For when i need to fix layout stuff
  /* notchState.set(NotchStateType.HOVERED)
  shouldRevealContent.set(true) */

  return (
    <window
      marginTop={5}
      className="Notch"
      gdkmonitor={gdkmonitor}
      anchor={TOP}
      exclusivity={Astal.Exclusivity.IGNORE}
      layer={Astal.Layer.TOP}
      application={App}
      visible
      heightRequest={30}
      width_request={100}
    >
      <eventbox
        halign={Gtk.Align.FILL}
        onHover={() => {
          notchState.set(NotchStateType.HOVERED)
        }}
        onHoverLost={() => {
          notchState.set(NotchStateType.NORMAL)
        }}
        className={`container notch`}
      >
        <box
          vertical
          spacing={spacingVariable()}
          css={notchState.get().as((state) => {
            return state === NotchStateType.HOVERED ? 'min-width: 500px; min-height: 350px;' : ''
          })}
        >
          <NotchHead />
          {shouldRenderContent().as((shouldRender) => {
            return shouldRender ? (
              <revealer
                revealChild={shouldRevealContent()}
                transitionType={Gtk.RevealerTransitionType.CROSSFADE}
                transitionDuration={Durations.TRANSITION}
              >
                <box
                  hexpand
                  vexpand
                  className="notch_content"
                >
                  <stack
                    visibleChildName={notchLayout.get().as((notchLayout) => notchLayout)}
                    transitionType={Gtk.StackTransitionType.CROSSFADE}
                    transitionDuration={100}
                  >
                    <HomeLayout />
                    <BluetoothLayout />
                  </stack>
                </box>
              </revealer>
            ) : (
              ''
            )
          })}
        </box>
      </eventbox>
    </window>
  )
}

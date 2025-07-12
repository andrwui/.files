import { AstalIO, bind, timeout, Variable } from 'astal'
import { Durations } from '@/constants/constants'
import ActionBarHead from './head/ActionBarHead'
import { Gtk } from 'astal/gtk3'
import HomeLayout from './layouts/home/HomeLayout'
import BluetoothLayout from './layouts/bluetooth/BluetoothLayout'
import WidgetPanelLayout, {
  WidgetPanelLayoutType,
} from '@/singleton/widget_panel_layout/WidgetPanelLayout'
import AstalBluetooth from 'gi://AstalBluetooth?version=0.1'

export function ActionBarWidgetPanel() {
  const isHovered = Variable<boolean>(false)

  const bluetooth = AstalBluetooth.get_default()
  const adapt = bluetooth.adapters[0]

  const widgetLayout = WidgetPanelLayout.getInstance()

  const shouldRevealHoveredContent = Variable<boolean>(false)
  const shouldRenderHoveredContent = Variable<boolean>(false)

  const spacingVariable = Variable.derive(
    [bind(isHovered), bind(shouldRevealHoveredContent)],
    (hovered, shouldReveal) => {
      return hovered && shouldReveal ? 0 : -5000
    },
  )

  let showTimeout = AstalIO.Time.timeout(0, () => {})

  // Subscriber for transitions
  isHovered.subscribe((hovered) => {
    if (hovered) {
      showTimeout = timeout(Durations.TRANSITION, () => {
        shouldRenderHoveredContent.set(true)
        shouldRevealHoveredContent.set(true)
      })
    } else {
      showTimeout.cancel()
      shouldRenderHoveredContent.set(false)
      timeout(Durations.TRANSITION, () => {
        shouldRevealHoveredContent.set(false)
      })
    }
  })

  // Subscriber for other stuff
  isHovered.subscribe((hovered) => {
    if (hovered) {
      widgetLayout.set(WidgetPanelLayoutType.HOME)
    } else {
      if (adapt.discovering) {
        adapt.stop_discovery()
      }
    }
  })

  return (
    <eventbox
      name="widgets"
      halign={Gtk.Align.FILL}
      onHover={() => {
        isHovered.set(true)
      }}
      onHoverLost={() => {
        isHovered.set(false)
      }}
    >
      <box
        spacing={spacingVariable()}
        vertical
        css={isHovered().as((state) => {
          return state ? 'min-width: 600px; min-height: 300px;' : ''
        })}
      >
        <ActionBarHead />
        {shouldRenderHoveredContent().as((shouldRender) => {
          return shouldRender ? (
            <revealer
              revealChild={shouldRevealHoveredContent()}
              transitionType={Gtk.RevealerTransitionType.CROSSFADE}
              transitionDuration={Durations.TRANSITION}
            >
              <box
                hexpand
                vexpand
                className="actionbar_content"
              >
                <stack
                  visibleChildName={widgetLayout.get().as((widgetLayout) => widgetLayout)}
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
  )
}

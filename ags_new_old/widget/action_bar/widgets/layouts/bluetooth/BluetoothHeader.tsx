import WidgetPanelLayout, {
  WidgetPanelLayoutType,
} from '@/singleton/widget_panel_layout/WidgetPanelLayout'
import { bind } from 'astal'
import AstalBluetooth from 'gi://AstalBluetooth?version=0.1'

export default function BluetoothHeader() {
  const widgetPanelLayout = WidgetPanelLayout.getInstance()
  const bluetooth = AstalBluetooth.get_default()
  const adap = bluetooth.adapters[0]

  return (
    <box
      hexpand
      spacing={10}
    >
      <box>
        <button
          className="back_button"
          onClick={() => widgetPanelLayout.set(WidgetPanelLayoutType.HOME)}
        >
          <icon
            className="title_icon"
            icon="i-arrow-left"
          />
        </button>
      </box>
      <box hexpand>
        <icon
          className="title_icon"
          icon="i-bluetooth"
        />
        <label
          className="title_title"
          label="Bluetooth"
        />
      </box>
      <button
        onClick={() => {
          if (adap.discovering) {
            adap.stop_discovery()
          } else {
            adap.start_discovery()
          }
        }}
      >
        <label
          label={bind(adap, 'discovering').as((isDiscovering) =>
            isDiscovering ? 'Stop scan' : 'Scan',
          )}
        />
      </button>
    </box>
  )
}

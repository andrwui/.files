import WidgetPanelLayout, {
  WidgetPanelLayoutType,
} from '@/singleton/widget_panel_layout/WidgetPanelLayout'

export default function BluetoothHeader() {
  const widgetPanelLayout = WidgetPanelLayout.getInstance()

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
      <box>
        <icon
          className="title_icon"
          icon="i-bluetooth"
        />
        <label
          className="title_title"
          label="Bluetooth"
        />
      </box>
    </box>
  )
}

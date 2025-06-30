import { Gtk } from 'astal/gtk3'

export default function BluetoothHeader() {
  return (
    <box hexpand>
      <icon
        className="title_icon"
        icon="i-bluetooth"
      />
      <label
        className="title_title"
        label="Bluetooth"
      />

      <box
        hexpand
        halign={Gtk.Align.FILL}
      >
        <label
          hexpand
          halign={Gtk.Align.END}
          className="title_scanning-label"
          label="Scanning..."
        />
      </box>
    </box>
  )
}

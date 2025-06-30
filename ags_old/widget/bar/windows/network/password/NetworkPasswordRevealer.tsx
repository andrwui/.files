import NetworkConnectButton from './components/NetworkConnectButton'
import { bind, execAsync } from 'astal'
import { selectedAp, password } from '../variables'
import { Gtk } from 'astal/gtk3'
import NetworkPasswordEntry from './components/NetworkPasswordEntry'

const NetworkPasswordRevealer = () => {
  const { FILL, START, END } = Gtk.Align

  return (
    <box>
      {bind(selectedAp).as((selectedApBind) => {
        return (
          <revealer revealChild={!!selectedApBind}>
            <box
              vertical
              spacing={10}
            >
              <box halign={FILL}>
                <label
                  halign={START}
                  label={`connecting to ${selectedApBind?.ssid}`}
                  hexpand
                />
                <eventbox
                  halign={END}
                  className={'smallText'}
                  onClick={() => selectedAp.set(null)}
                >
                  X
                </eventbox>
              </box>
              <NetworkPasswordEntry />
              <NetworkConnectButton />
            </box>
          </revealer>
        )
      })}
    </box>
  )
}

export default NetworkPasswordRevealer

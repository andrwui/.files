import { bind, Variable } from 'astal'
import Cava from 'gi://AstalCava'
import Gtk from 'gi://Gtk?version=3.0'
const cava = Cava.get_default()
cava?.set_bars(4)
cava?.set_noise_reduction(0.5)

const bars = Variable('')
const blocks = ['\u2581', '\u2582', '\u2583', '\u2584', '\u2585', '\u2586', '\u2587', '\u2588']

export default function AudioVisualizer() {
  cava?.connect('notify::values', () => {
    let b = ''
    cava.get_values().map((val) => (b += blocks[Math.min(Math.floor(val * 8), blocks.length - 1)]))
    bars.set(b)
  })
  return (
    <box
      halign={Gtk.Align.START}
      name="cava"
      onDestroy={() => cava?.disconnect}
      css={`
        transition: 250ms;
        font-size: 12px;
      `}
    >
      <label
        valign={Gtk.Align.END}
        marginBottom={10}
        onDestroy={() => bars.drop()}
        label={bind(bars)}
      />
    </box>
  )
}

import { subprocess, Variable } from 'astal'
import UsageMeter from './UsageMeter'
import { Gtk } from 'astal/gtk3'

export type Metrics = {
  CPU: number
  RAM: number
  DISK: number
  NET_DOWN: number
  NET_UP: number
}

export default function UsagePanel() {
  const metrics = Variable<Metrics>({
    CPU: 0,
    RAM: 0,
    DISK: 0,
    NET_DOWN: 0,
    NET_UP: 0,
  })

  subprocess('/home/andrw/.files/ags/bins/metrics', (out) => {
    const jsonMetrics: Metrics = JSON.parse(out)
    metrics.set(jsonMetrics)
  })

  return (
    <box>
      <UsageMeter
        halign={Gtk.Align.START}
        metrics={metrics}
        metric="CPU"
        icon="i-cpu"
        progress
      />
      <UsageMeter
        halign={Gtk.Align.CENTER}
        metrics={metrics}
        metric="RAM"
        icon="i-ram"
        progress
      />
      <UsageMeter
        halign={Gtk.Align.END}
        metrics={metrics}
        metric="DISK"
        icon="i-disk"
        progress
      />
    </box>
  )
}

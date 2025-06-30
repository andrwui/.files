import { Binding, Variable } from 'astal'
import { Gtk } from 'astal/gtk3'
import { Metrics } from './UsagePanel'

type UsageMeterProps = {
  metrics: Variable<Metrics>
  metric: keyof Metrics
  icon: string
  halign?: Gtk.Align | Binding<Gtk.Align | undefined>
  progress?: boolean
}

export default function UsageMeter({ metric, metrics, icon, halign, progress }: UsageMeterProps) {
  return (
    <box
      vertical
      halign={halign}
    >
      {progress ? (
        <circularprogress
          sensitive={false}
          startAt={0.75}
          end_at={0.75}
          css={`
            color: white;
            background-color: #1a1a1a;
            font-size: 6px;
            min-width: 2px;
          `}
          value={metrics().as((vals) => {
            return vals[metric] / 100
          })}
        >
          <icon
            icon={icon}
            className="stats_icon"
            css={'font-size: 4em; padding: .5em;'}
          />
        </circularprogress>
      ) : (
        <icon
          icon={icon}
          className="stats_icon"
          css={'font-size: 2em; padding: .35em;'}
        />
      )}
      <label label={metrics().as((metrics) => String(Math.ceil(metrics[metric])) + '%')} />
    </box>
  )
}
